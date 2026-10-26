CLASS zcl_sap_ids_scim_api DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES zif_sap_ids_scim_user_api .
    INTERFACES zif_sap_ids_scim_group_api .

    ALIASES create_group
      FOR zif_sap_ids_scim_group_api~create_group .
    ALIASES create_user
      FOR zif_sap_ids_scim_user_api~create_user .
    ALIASES delete_group
      FOR zif_sap_ids_scim_group_api~delete_group .
    ALIASES delete_user
      FOR zif_sap_ids_scim_user_api~delete_user .
    ALIASES get_group
      FOR zif_sap_ids_scim_group_api~get_group .
    ALIASES get_user
      FOR zif_sap_ids_scim_user_api~get_user .
    ALIASES patch_user
      FOR zif_sap_ids_scim_user_api~patch_user .
    ALIASES search_groups
      FOR zif_sap_ids_scim_group_api~search_groups .
    ALIASES search_users
      FOR zif_sap_ids_scim_user_api~search_users .
    ALIASES update_group
      FOR zif_sap_ids_scim_group_api~update_group .
    ALIASES update_user
      FOR zif_sap_ids_scim_user_api~update_user .
    ALIASES add_group_member
      FOR zif_sap_ids_scim_group_api~add_group_member.
    ALIASES add_group_members
      FOR zif_sap_ids_scim_group_api~add_group_members.
    ALIASES remove_group_member
      FOR zif_sap_ids_scim_group_api~remove_group_member.
    ALIASES ts_group
      FOR zif_sap_ids_scim_group_api~ts_group .
    ALIASES ts_groups
      FOR zif_sap_ids_scim_group_api~ts_groups .
    ALIASES ts_user
      FOR zif_sap_ids_scim_user_api~ts_user .
    ALIASES ts_users
      FOR zif_sap_ids_scim_user_api~ts_users .

    "! Get an instance of the SCIM API class for the specified RFC destination
    "! @parameter destination_name | Name of the RFC destination configured in the SAP system
    "! @parameter instance | Instance of the SCIM API class
    "! @raising zcx_sap_ids_scim_api | SCIM API Error
    CLASS-METHODS get_instance
      IMPORTING
        !destination_name TYPE rfcdest
      RETURNING
        VALUE(instance)   TYPE REF TO zcl_sap_ids_scim_api
      RAISING
        zcx_sap_ids_scim_api.

    "! Close the connection to the SCIM API
    "! @raising zcx_sap_ids_scim_api | SCIM API Error
    METHODS close_connection
      RAISING
        zcx_sap_ids_scim_api.

  PROTECTED SECTION.

  PRIVATE SECTION.

    CONSTANTS: BEGIN OF endpoint,
                 users  TYPE string VALUE '/scim/Users',
                 groups TYPE string VALUE '/scim/Groups',
               END   OF endpoint.

    DATA destination_name TYPE rfcdest.
    DATA http_client TYPE REF TO if_http_client.

    "! Constructor is private to enforce the use of the get_instance method for creating instances
    "! @parameter destination_name | Name of the RFC destination configured in the SAP system
    "! @parameter http_client | HTTP client object for the established connection
    METHODS constructor
      IMPORTING
        !destination_name TYPE rfcdest
        !http_client      TYPE REF TO if_http_client.

    "! Create connection to the SCIM API using the provided destination name
    "! @parameter destination_name | Name of the RFC destination configured in the SAP system
    "! @parameter http_client | HTTP client object for the established connection
    "! @raising zcx_sap_ids_scim_api | SCIM API Error
    CLASS-METHODS create_connection
      IMPORTING
        !destination_name  TYPE rfcdest
      RETURNING
        VALUE(http_client) TYPE REF TO if_http_client
      RAISING
        zcx_sap_ids_scim_api.

    "! Send an HTTP request to the SCIM API
    "! @parameter uri | URI of the SCIM API endpoint
    "! @parameter payload | Optional payload for the request (for POST and PUT methods)
    "! @parameter method | HTTP method (GET, POST, PUT, DELETE)
    "! @parameter content_type | Content type of the request (default: application/scim+json)
    "! @parameter response | HTTP response object returned by the SCIM API
    "! @raising zcx_sap_ids_scim_api | SCIM API Error
    METHODS send_request
      IMPORTING
        !uri            TYPE string
        !payload        TYPE string OPTIONAL
        !method         TYPE string DEFAULT 'GET'
        !content_type   TYPE string DEFAULT 'application/scim+json'
      RETURNING
        VALUE(response) TYPE REF TO if_http_response
      RAISING
        zcx_sap_ids_scim_api.

    "! Serialize a user structure into a JSON string
    "! @parameter user | User structure to be serialized
    "! @parameter json | Serialized JSON string representation of the user structure
    METHODS serialize_user
      IMPORTING
        !user       TYPE ts_user
      RETURNING
        VALUE(json) TYPE string.

    "! Serialize a group structure into a JSON string
    "! @parameter group | Group structure to be serialized
    "! @parameter json | Serialized JSON string representation of the group structure
    METHODS serialize_group
      IMPORTING
        group       TYPE ts_group
      RETURNING
        VALUE(json) TYPE string.

    "! Deserialize a JSON string into a user structure
    "! @parameter json | JSON string representation of the user structure
    "! @parameter user | Deserialized user structure
    METHODS deserialize_user
      IMPORTING
        !json       TYPE string
      RETURNING
        VALUE(user) TYPE ts_user.

    	"! Deserialize a JSON string into a list of user structures
    "! @parameter json | JSON string representation of the list of users
    "! @parameter users | Deserialized list of users
    METHODS deserialize_users
      IMPORTING
        !json        TYPE string
      RETURNING
        VALUE(users) TYPE ts_users.

    "! Deserialize a JSON string into a group structure
    "! @parameter json | JSON string representation of the group structure
    "! @parameter group | Deserialized group structure
    METHODS deserialize_group
      IMPORTING
        json         TYPE string
      RETURNING
        VALUE(group) TYPE ts_group.

    "! Deserialize a JSON string into a list of group structures
    "! @parameter json | JSON string representation of the list of groups
    "! @parameter groups | Deserialized list of groups
    METHODS deserialize_groups
      IMPORTING
        json          TYPE string
      RETURNING
        VALUE(groups) TYPE ts_groups.

ENDCLASS.



CLASS zcl_sap_ids_scim_api IMPLEMENTATION.


  METHOD close_connection.

    http_client->close(
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid = zcx_sap_ids_scim_api=>close_connection_failed.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    me->http_client = http_client.
    me->destination_name = destination_name.

  ENDMETHOD.


  METHOD create_connection.

    CALL METHOD cl_http_client=>create_by_destination
      EXPORTING
        destination              = destination_name
      IMPORTING
        client                   = http_client
      EXCEPTIONS
        argument_not_found       = 1
        destination_not_found    = 2
        destination_no_authority = 3
        plugin_not_active        = 4
        internal_error           = 5
        OTHERS                   = 6.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid = zcx_sap_ids_scim_api=>create_connection_failed.
    ENDIF.

  ENDMETHOD.


  METHOD deserialize_group.

    DATA new_json TYPE string.

    new_json = json.

    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_group_api~custom_extension-json_name
      IN new_json WITH zif_sap_ids_scim_group_api~custom_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = group ).

  ENDMETHOD.


  METHOD deserialize_groups.

    DATA new_json TYPE string.

    new_json = json.

    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_group_api~custom_extension-json_name
      IN new_json WITH zif_sap_ids_scim_group_api~custom_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = groups ).

  ENDMETHOD.


  METHOD deserialize_user.

    DATA new_json TYPE string.

    new_json = json.

    " Custom Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~custom_extension-json_name
      IN new_json WITH zif_sap_ids_scim_user_api~custom_extension-abap_name.

    " Enterprise Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~enterprise_extension-json_name
      IN new_json WITH zif_sap_ids_scim_user_api~enterprise_extension-abap_name.

    " SAP Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~sap_extension-json_name
      IN new_json WITH zif_sap_ids_scim_user_api~sap_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = user ).

  ENDMETHOD.


  METHOD deserialize_users.

    " Extensions are deserialize to their ABAP names, but the SCIM API returned them .
    " Therefore, we need to replace the JSON long names with the ABAP names in the deserialized JSON string.

    DATA new_json TYPE string.

    new_json = json.

    " Custom Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~custom_extension-json_name
      IN new_json WITH zif_sap_ids_scim_user_api~custom_extension-abap_name.

    " Enterprise Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~enterprise_extension-json_name
      IN new_json WITH zif_sap_ids_scim_user_api~enterprise_extension-abap_name.

    " SAP Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~sap_extension-json_name
      IN new_json WITH zif_sap_ids_scim_user_api~sap_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = users ).

  ENDMETHOD.


  METHOD get_instance.

    DATA http_client TYPE REF TO if_http_client.

    http_client = create_connection( destination_name ).

    CREATE OBJECT instance
      EXPORTING
        destination_name = destination_name
        http_client      = http_client.

  ENDMETHOD.


  METHOD send_request.

    DATA payload_x TYPE xstring.

    cl_http_utility=>set_request_uri(
      request = http_client->request
      uri     = uri ).

    IF payload IS NOT INITIAL.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = payload
        IMPORTING
          buffer = payload_x.

      http_client->request->set_data( payload_x ).
    ENDIF.

    http_client->request->set_method( method ).
    http_client->request->set_content_type( content_type ).

    http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid = zcx_sap_ids_scim_api=>send_request_failed.
    ENDIF.

    http_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid = zcx_sap_ids_scim_api=>receive_response_failed.
    ENDIF.

    response = http_client->response.

  ENDMETHOD.


  METHOD serialize_group.

    json = /ui2/cl_json=>serialize(
      data        = group
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_group_api~custom_extension-abap_name
      IN json WITH zif_sap_ids_scim_group_api~custom_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD serialize_user.

    " Extensions are serialized with their ABAP names, but the SCIM API expects the JSON names.
    " Therefore, we need to replace the ABAP names with the JSON names in the serialized JSON string.

    json = /ui2/cl_json=>serialize(
      data        = user
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    " Custom Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~custom_extension-abap_name
      IN json WITH zif_sap_ids_scim_user_api~custom_extension-json_name.

    " Enterprise Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~enterprise_extension-abap_name
      IN json WITH zif_sap_ids_scim_user_api~enterprise_extension-json_name.

    " Core Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~core_extension-abap_name
      IN json WITH zif_sap_ids_scim_user_api~core_extension-json_name.

    " SAP Extension
    REPLACE ALL OCCURRENCES OF zif_sap_ids_scim_user_api~sap_extension-abap_name
      IN json WITH zif_sap_ids_scim_user_api~sap_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~create_group.

    DATA(response) = send_request(
      uri     = endpoint-groups
      payload = serialize_group( payload )
      method  = 'POST' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 201.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>create_group_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    group = deserialize_group( json ).

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~delete_group.

    DATA uri TYPE string.

    CHECK id IS NOT INITIAL.

    uri = endpoint-groups && '/' && id.

    DATA(response) = send_request(
      uri    = uri
      method = 'DELETE' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>delete_group_failed
          group_id    = id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~get_group.

    DATA uri TYPE string.

    uri = endpoint-groups && '/' && id.

    IF attributes IS NOT INITIAL.
      uri = uri && '?attributes=' && attributes.
    ENDIF.

    IF excluded_attributes IS NOT INITIAL.
      IF attributes IS NOT INITIAL.
        uri = uri && '&'.
      ELSE.
        uri = uri && '?'.
      ENDIF.

      uri = uri && 'excludedAttributes=' && excluded_attributes.
    ENDIF.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>get_group_failed
          group_id    = id
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    group = deserialize_group( json ).

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~search_groups.

    DATA uri TYPE string VALUE endpoint-groups.

    DATA filter TYPE string.

    IF count IS NOT INITIAL.
      filter = 'count=' && count.
    ENDIF.

    IF start_index IS NOT INITIAL.
      IF count IS NOT INITIAL.
        filter = filter && '&'.
      ENDIF.

      filter = filter && 'startIndex=' && start_index.
    ENDIF.

    IF filter IS NOT INITIAL.
      uri = uri && '?' && filter.
    ENDIF.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>search_groups_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    groups = deserialize_groups( json ).

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~update_group.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_user_api~create_user.

    DATA(response) = send_request(
      uri     = endpoint-users
      payload = serialize_user( payload )
      method  = 'POST' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 201.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>create_user_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    user = deserialize_user( json ).

  ENDMETHOD.


  METHOD zif_sap_ids_scim_user_api~delete_user.

    DATA uri TYPE string.

    CHECK id IS NOT INITIAL.

    uri = endpoint-users && '/' && id.

    DATA(response) = send_request(
      uri    = uri
      method = 'DELETE' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>delete_user_failed
          user_id     = id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_user_api~get_user.

    DATA uri TYPE string.

    uri = endpoint-users && '/' && id.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>get_user_failed
          user_id     = id
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    user = deserialize_user( json ).

  ENDMETHOD.


  METHOD zif_sap_ids_scim_user_api~patch_user.

    " Not implemented yet, will required a dynamic payload to be created based on the patch operations provided by the user.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_user_api~search_users.

    DATA uri TYPE string VALUE endpoint-users.

    IF filter IS NOT INITIAL.
      uri = uri && '?' && filter.
    ENDIF.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>search_users_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    users = deserialize_users( json ).

  ENDMETHOD.


  METHOD zif_sap_ids_scim_user_api~update_user.

    DATA uri TYPE string.

    CHECK user-id IS NOT INITIAL.

    uri = endpoint-users && '/' && user-id.

    DATA(response) = send_request(
      uri     = uri
      payload = serialize_user( user )
      method  = 'PUT' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>update_user_failed
          user_id     = user-id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~add_group_member.

    DATA payload TYPE zif_sap_ids_scim_group_api~ts_patch_add_payload.

    DATA uri TYPE string.

    CHECK group_id IS NOT INITIAL AND user_id IS NOT INITIAL.

    APPEND INITIAL LINE TO payload-schemas ASSIGNING FIELD-SYMBOL(<schema>).
    <schema> = 'urn:ietf:params:scim:api:messages:2.0:PatchOp'.

    APPEND INITIAL LINE TO payload-operations ASSIGNING FIELD-SYMBOL(<operation>).
    <operation>-op = 'add'.
    <operation>-path = 'members'.
    APPEND INITIAL LINE TO <operation>-value ASSIGNING FIELD-SYMBOL(<member>).
    <member>-value = user_id.

    DATA(json) = /ui2/cl_json=>serialize(
      data        = payload
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    uri = endpoint-groups && '/' && group_id.

    DATA(response) = send_request(
      uri     = uri
      payload = json
      method  = 'PATCH' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>update_group_failed
          group_id    = group_id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~add_group_members.

    DATA payload TYPE zif_sap_ids_scim_group_api~ts_patch_add_payload.

    DATA uri TYPE string.

    CHECK group_id IS NOT INITIAL AND user_ids IS NOT INITIAL.

    APPEND INITIAL LINE TO payload-schemas ASSIGNING FIELD-SYMBOL(<schema>).
    <schema> = 'urn:ietf:params:scim:api:messages:2.0:PatchOp'.

    APPEND INITIAL LINE TO payload-operations ASSIGNING FIELD-SYMBOL(<operation>).
    <operation>-op    = 'add'.
    <operation>-path  = 'members'.
    <operation>-value = user_ids.

    DATA(json) = /ui2/cl_json=>serialize(
      data        = payload
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    uri = endpoint-groups && '/' && group_id.

    DATA(response) = send_request(
      uri     = uri
      payload = json
      method  = 'PATCH' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>update_group_failed
          group_id    = group_id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_sap_ids_scim_group_api~remove_group_member.

    DATA payload TYPE zif_sap_ids_scim_group_api~ts_patch_remove_payload.

    DATA uri TYPE string.

    CHECK group_id IS NOT INITIAL AND user_id IS NOT INITIAL.

    APPEND INITIAL LINE TO payload-schemas ASSIGNING FIELD-SYMBOL(<schema>).
    <schema> = 'urn:ietf:params:scim:api:messages:2.0:PatchOp'.

    APPEND INITIAL LINE TO payload-operations ASSIGNING FIELD-SYMBOL(<operation>).
    <operation>-op = 'remove'.
    <operation>-path = 'members[value eq "' && user_id && '"]'.

    DATA(json) = /ui2/cl_json=>serialize(
      data        = payload
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    uri = endpoint-groups && '/' && group_id.

    DATA(response) = send_request(
      uri     = uri
      payload = json
      method  = 'PATCH' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_sap_ids_scim_api
        EXPORTING
          textid      = zcx_sap_ids_scim_api=>update_group_failed
          group_id    = group_id
          status_code = status_code
          reason      = reason.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
