# SAP Identity Directory Service SCIM API for ABAP

An ABAP wrapper for the SAP Identity Directory Service SCIM API, distributed with abapGit. It provides typed user and group resources, JSON conversion, HTTP requests, and checked exceptions for API failures.

The wrapper calls `/scim/Users` and `/scim/Groups` with the content type `application/scim+json`.

## Requirements and Installation

1. Import this repository into an ABAP package using [abapGit](https://abapgit.org/) and activate the imported objects, including message class `ZSAP_IDS_SCIM`.
2. Ensure the system provides `/UI2/CL_JSON`, `CL_HTTP_CLIENT`, `CL_HTTP_UTILITY`, and function module `SCMS_STRING_TO_XSTRING`. The source uses modern ABAP syntax, including inline declarations; verify compatibility on your target system. This repository does not specify a minimum supported ABAP release.
3. Configure an HTTP connection to an external server (type G) in transaction `SM59`, for example `Z_IDS_SCIM`:
	 - Set the target host to your Identity Directory Service tenant host, without a URL scheme.
	 - Configure HTTPS and the appropriate service/port, typically `443`.
	 - Configure the authentication required by your tenant and give the technical identity permission for the operations you intend to call.
	 - Configure the SSL client PSE and certificate trust as required by your system, using `STRUST`.
	 - Do not rely on a destination path prefix to select another API version: the wrapper explicitly sets each request URI to `/scim/Users` or `/scim/Groups` and their resource paths.
4. Verify connectivity and authorizations before running the examples against a non-production tenant.

The wrapper creates its HTTP client with `CL_HTTP_CLIENT=>CREATE_BY_DESTINATION`. It does not accept credentials, acquire tokens, or configure authentication itself. Keep credentials out of ABAP source code and manage authentication through your system's destination setup.

## Main Objects

| Object | Purpose |
| --- | --- |
| [ZCL_SAP_IDS_SCIM_API](src/zcl_sap_ids_scim_api.clas.abap) | Concrete client; implements both API interfaces and exposes method/type aliases. |
| [ZIF_SAP_IDS_SCIM_USER_API](src/zif_sap_ids_scim_user_api.intf.abap) | User operations, resource types, and schema constants. |
| [ZIF_SAP_IDS_SCIM_GROUP_API](src/zif_sap_ids_scim_group_api.intf.abap) | Group operations, membership operations, resource types, and schema constants. |
| [ZCX_SAP_IDS_SCIM_API](src/zcx_sap_ids_scim_api.clas.abap) | Checked exception for connection, transport, and unexpected HTTP status failures. |

Use `ZCL_SAP_IDS_SCIM_API=>GET_INSTANCE` rather than `NEW`: the constructor is private. Each factory call creates a new client and connection; it is not a cached singleton. Close the connection when finished.

## Quick Start

This read-only report lists the first page of users and handles connection cleanup even if the request fails. Replace `Z_IDS_SCIM` with your destination name.

```abap
REPORT z_ids_scim_example.

DATA api TYPE REF TO zcl_sap_ids_scim_api.

TRY.
		api = zcl_sap_ids_scim_api=>get_instance(
			destination_name = 'Z_IDS_SCIM' ).

		DATA(users) = api->search_users( ).

		WRITE: / 'Total users:', users-total_results.
		LOOP AT users-resources INTO DATA(user).
			WRITE: / user-id, user-user_name, user-display_name.
		ENDLOOP.

	CATCH zcx_sap_ids_scim_api INTO DATA(api_error).
		WRITE: / api_error->get_text( ).
		WRITE: / 'HTTP status:', api_error->status_code,
						 'Reason:', api_error->reason.
ENDTRY.

IF api IS BOUND.
	TRY.
			api->close_connection( ).
		CATCH zcx_sap_ids_scim_api INTO DATA(close_error).
			WRITE: / close_error->get_text( ).
	ENDTRY.
ENDIF.
```

The snippets below assume an open client named `api`. Run them inside a `TRY ... CATCH zcx_sap_ids_scim_api` block and close the connection afterward, as above. Creation, update, membership, and deletion examples change tenant data.

## Users

### Create a User

Build a `TS_USER` payload. Supply the applicable schema URNs and the attributes required by your tenant. The returned resource contains the server-assigned `id`; use that ID for subsequent resource operations, not the login name.

```abap
DATA new_user TYPE zif_sap_ids_scim_user_api=>ts_user.

new_user-schemas = VALUE #(
	( zif_sap_ids_scim_user_api=>core_extension-json_name ) ).
new_user-user_name = 'alex@example.com'.
new_user-name-given_name = 'Alex'.
new_user-name-family_name = 'Example'.
new_user-display_name = 'Alex Example'.
new_user-active = abap_true.
new_user-emails = VALUE #(
	( value = 'alex@example.com' primary = abap_true ) ).

DATA(created_user) = api->create_user( payload = new_user ).
WRITE: / 'Created user:', created_user-id.
```

### Read and Search Users

```abap
DATA(existing_user) = api->get_user( id = 'USER_RESOURCE_ID' ).

DATA(filter_expression) = cl_http_utility=>escape_url(
	unescaped = 'userName eq "alex@example.com"' ).

DATA(matching_users) = api->search_users(
	filter = |filter={ filter_expression }&count=100&startIndex=1| ).

LOOP AT matching_users-resources INTO DATA(matching_user).
	WRITE: / matching_user-id, matching_user-user_name.
ENDLOOP.
```

Despite its name, the `filter` argument is the **complete query string without the leading `?`**. The implementation appends `?` followed by the supplied string verbatim. Include `filter=` for a SCIM filter and URL-encode query parameter values yourself; do not encode the whole query string, including its `&` and `=` separators.

Calling `search_users( )` without arguments requests the service's default page. The returned `TS_USERS` contains `resources`, `total_results`, `items_per_page`, and `start_index`, as well as `start_id`, `next_id`, and `next_cursor` if supplied by the service. Pagination is manual: pass query parameters supported by your tenant to retrieve further pages. The wrapper does not follow cursors or collect all results automatically.

### Update a User

`update_user` sends a **PUT**, not a partial update. Read the user first, change the desired fields, and submit the resource with its `id` populated. Review the tenant's replacement semantics before using this in production; attributes absent from the payload can be affected.

```abap
DATA(user_to_update) = api->get_user( id = 'USER_RESOURCE_ID' ).
user_to_update-display_name = 'Alex Updated'.
api->update_user( user = user_to_update ).
```

The method returns no resource. Use `get_user` in a fresh client if you need to verify the stored result; see the connection reuse limitation below.

**`patch_user` is declared but not implemented.** Calling it currently does nothing and raises no unsupported-operation exception. Do not use it for partial updates.

### Delete a User

```abap
api->delete_user( id = 'USER_RESOURCE_ID' ).
```

Deletion is destructive and, according to the interface contract, also removes the user's membership assignments. An initial/empty ID causes this method to return without sending a request.

## Groups

### Create a Group

```abap
DATA new_group TYPE zif_sap_ids_scim_group_api=>ts_group.

new_group-schemas = VALUE #(
	( zif_sap_ids_scim_group_api=>core_schema )
	( zif_sap_ids_scim_group_api=>custom_extension-json_name ) ).
new_group-display_name = 'Store Managers'.
new_group-group_ext-name = 'store-managers'.
new_group-group_ext-description = 'Store management team'.

DATA(created_group) = api->create_group( payload = new_group ).
WRITE: / 'Created group:', created_group-id.
```

The custom extension is optional; omit its schema and fields if not needed. Use the returned `id` as `group_id` in membership operations.

### Read and List Groups

```abap
DATA(existing_group) = api->get_group( id = 'GROUP_RESOURCE_ID' ).

DATA(group_summary) = api->get_group(
	id         = 'GROUP_RESOURCE_ID'
	attributes = 'id,displayName' ).

DATA(group_without_members) = api->get_group(
	id                  = 'GROUP_RESOURCE_ID'
	excluded_attributes = 'members' ).

DATA(group_page) = api->search_groups( count = 100 start_index = 1 ).
LOOP AT group_page-resources INTO DATA(listed_group).
	WRITE: / listed_group-id, listed_group-display_name.
ENDLOOP.
```

`attributes` and `excluded_attributes` take comma-separated SCIM attribute names. Their values are appended to the URL without encoding. Fields not returned by the service remain initial in the ABAP structure.

`search_groups` supports only `count` and `start_index`; there is no group-filter argument. It returns one `TS_GROUPS` page with `resources`, `total_results`, `items_per_page`, and `start_index`. To retrieve subsequent pages, call it again with the next start index based on the returned page. Guard pagination loops against empty pages. Initial numeric arguments are omitted from the query.

### Manage Membership

These helpers construct SCIM `PatchOp` payloads and send `PATCH` requests to the group resource. Pass SCIM user resource IDs, not user names or email addresses.

```abap
api->add_group_member(
	group_id = 'GROUP_RESOURCE_ID'
	user_id  = 'USER_RESOURCE_ID' ).

DATA members_to_add TYPE zif_sap_ids_scim_group_api=>tt_op_member.
members_to_add = VALUE #(
	( value = 'FIRST_USER_RESOURCE_ID' )
	( value = 'SECOND_USER_RESOURCE_ID' ) ).

api->add_group_members(
	group_id = 'GROUP_RESOURCE_ID'
	user_ids = members_to_add ).

api->remove_group_member(
	group_id = 'GROUP_RESOURCE_ID'
	user_id  = 'USER_RESOURCE_ID' ).
```

`add_group_members` sends the supplied table in a single request; it does not split large batches. Membership helpers return without sending a request if the group ID or required user ID/table is initial. Validate IDs inside a nonempty table yourself.

### Delete or Update a Group

```abap
api->delete_group( id = 'GROUP_RESOURCE_ID' ).
```

An initial/empty ID causes deletion to return without sending a request.

**`update_group` is declared but not implemented.** It currently does nothing. Use the membership helpers for supported membership changes; general group attribute updates are not available through this wrapper.

## Resource Types and JSON Mapping

User resources use `ZIF_SAP_IDS_SCIM_USER_API=>TS_USER`; group resources use `ZIF_SAP_IDS_SCIM_GROUP_API=>TS_GROUP`. The concrete class also exposes `ts_user`, `ts_users`, `ts_group`, and `ts_groups` as aliases, for example `ZCL_SAP_IDS_SCIM_API=>TS_USER`.

- ABAP fields use underscores (`user_name`, `display_name`, `phone_numbers`); serialization converts them to camelCase JSON names (`userName`, `displayName`, `phoneNumbers`).
- Boolean fields use `abap_bool`. Serialization uses `/UI2/CL_JSON` with `compress = abap_true`, so initial fields may be omitted. Do not assume that setting a field to its initial value will explicitly clear it or send JSON `false`.
- `ref` maps to the SCIM JSON field `$ref`.
- User `custom_ext-attributes` is a table of `name`/`value` pairs, mapped to `urn:sap:cloud:scim:schemas:extension:custom:2.0:User`.
- User `sap_ext` maps to `urn:ietf:params:scim:schemas:extension:sap:2.0:User`, including fields such as `source_system`, `user_uuid`, `send_mail`, and `status`.
- Group `group_ext` maps to `urn:sap:cloud:scim:schemas:extension:custom:2.0:Group`, with `additional_id`, `name`, and `description`.

Add each applicable extension URN to the resource's `schemas` table when supplying extension data; the wrapper does not populate that table for you.

Although enterprise schema constants and employee-related helper types exist, `TS_USER` does not contain an `enterprise_ext` component. Enterprise employee attributes are therefore not accessible through the current typed user payload. The wrapper is not a lossless representation of every SCIM attribute: service fields absent from the ABAP types are not retained for a subsequent PUT.

## Method Reference

All implemented operations below can raise `ZCX_SAP_IDS_SCIM_API`. The status column shows the exact HTTP status accepted by the current implementation, not every status allowed by SCIM.

| Method | Main arguments | Request | Return / expected status |
| --- | --- | --- | --- |
| `get_instance` | `destination_name` | Creates destination-based client | Client reference |
| `close_connection` | None | Closes HTTP client | No return value |
| `create_user` | `payload: ts_user` | `POST /scim/Users` | `ts_user` / `201` |
| `get_user` | `id` | `GET /scim/Users/{id}` | `ts_user` / `200` |
| `search_users` | `filter` (optional query string) | `GET /scim/Users?...` | `ts_users` / `200` |
| `update_user` | `user: ts_user` | `PUT /scim/Users/{id}` | No return value / `200` |
| `delete_user` | `id` | `DELETE /scim/Users/{id}` | No return value / `204` |
| `patch_user` | `id`, `payload: string` | **Not implemented** | No action |
| `create_group` | `payload: ts_group` | `POST /scim/Groups` | `ts_group` / `201` |
| `get_group` | `id`, optional `attributes`, `excluded_attributes` | `GET /scim/Groups/{id}?...` | `ts_group` / `200` |
| `search_groups` | Optional `count`, `start_index` | `GET /scim/Groups?...` | `ts_groups` / `200` |
| `delete_group` | `id` | `DELETE /scim/Groups/{id}` | No return value / `204` |
| `add_group_member` | `group_id`, `user_id` | `PATCH /scim/Groups/{id}` | No return value / `204` |
| `add_group_members` | `group_id`, `user_ids: tt_op_member` | `PATCH /scim/Groups/{id}` | No return value / `204` |
| `remove_group_member` | `group_id`, `user_id` | `PATCH /scim/Groups/{id}` | No return value / `204` |
| `update_group` | `group: ts_group` | **Not implemented** | No action |

## Error Handling and Current Limitations

Catch `ZCX_SAP_IDS_SCIM_API` and use `get_text( )` for its message. For rejected HTTP responses, inspect `status_code`, `reason`, and, where populated, `user_id` or `group_id`. Connection and transport failures do not populate HTTP status details. The exception does not expose the SCIM response body or parsed `detail`/`scimType` fields.

- Check destination configuration, SSL trust, network connectivity, and runtime destination authorization for connection/transport failures.
- For HTTP `401` or `403`, check the destination's authentication and the technical identity's API permissions.
- For HTTP `400`, check required attributes, schema URNs, and query syntax; for `404`, check the resource ID; for `409`, check for conflicting resource values. Consult tenant-side diagnostics when the HTTP reason is insufficient.
- There is no automatic retry, rate-limit handling, or pagination. A response status different from the exact expected status raises an exception, even if another deployment accepts that status as successful.
- The shared HTTP request body is set only when a nonempty payload is supplied; it is not explicitly cleared before GET or DELETE requests. Use a fresh client when switching from a payload-bearing operation to a payload-free operation to avoid carrying over the previous body.
- IDs and query values are concatenated into request URIs without automatic URL encoding. Use valid service-issued IDs and encode query values where necessary.
- `patch_user` and `update_group` are silent no-ops, and some methods silently skip requests with initial IDs. A call that returns without an exception is not always evidence of a server-side change.

The examples describe the implementation in this repository. Validate them in your ABAP system against your tenant's schema requirements and API behavior before production use.
