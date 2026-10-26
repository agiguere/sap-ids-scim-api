INTERFACE zif_sap_ids_scim_group_api
  PUBLIC .

  CONSTANTS: core_schema TYPE string VALUE 'urn:ietf:params:scim:schemas:core:2.0:Group'.

  CONSTANTS: BEGIN OF custom_extension,
               json_name TYPE string VALUE 'urn:sap:cloud:scim:schemas:extension:custom:2.0:Group',
               abap_name TYPE string VALUE 'groupExt',
             END   OF custom_extension.

  TYPES: BEGIN OF ts_meta,
           created       TYPE string,
           last_modified TYPE string,
           location      TYPE string,
           resource_type TYPE string,
           version       TYPE string,
         END   OF ts_meta.

  TYPES: BEGIN OF ts_member,
           value TYPE string,
           type  TYPE string,
           ref   TYPE string,
         END   OF ts_member.

  TYPES: tt_member TYPE STANDARD TABLE OF ts_member.

  TYPES: BEGIN OF ts_op_member,
           value TYPE string,
         END   OF ts_op_member.

  TYPES: tt_op_member TYPE STANDARD TABLE OF ts_op_member.

  TYPES: BEGIN OF ts_group_extension,
           additional_id TYPE string,
           name          TYPE string,
           description   TYPE string,
         END   OF ts_group_extension.

  TYPES: BEGIN OF ts_group,
           id           TYPE string,
           display_name TYPE string,
           schemas      TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           members      TYPE STANDARD TABLE OF ts_member WITH DEFAULT KEY,
           group_ext    TYPE ts_group_extension,
           meta         TYPE ts_meta,
         END   OF ts_group.

  TYPES: BEGIN OF ts_groups,
           schemas        TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           total_results  TYPE i,
           items_per_page TYPE i,
           start_index    TYPE i,
           resources      TYPE STANDARD TABLE OF ts_group WITH DEFAULT KEY,
         END   OF ts_groups.

  TYPES: BEGIN OF ts_patch_remove_operation,
           op   TYPE string,
           path TYPE string,
         END   OF ts_patch_remove_operation.

  TYPES: BEGIN OF ts_patch_add_operation,
           op    TYPE string,
           path  TYPE string,
           value TYPE STANDARD TABLE OF ts_op_member WITH DEFAULT KEY,
         END   OF ts_patch_add_operation.

  TYPES: BEGIN OF ts_patch_add_payload,
           schemas    TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           operations TYPE STANDARD TABLE OF ts_patch_add_operation WITH DEFAULT KEY,
         END   OF ts_patch_add_payload.

  TYPES: BEGIN OF ts_patch_remove_payload,
           schemas    TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           operations TYPE STANDARD TABLE OF ts_patch_remove_operation WITH DEFAULT KEY,
         END   OF ts_patch_remove_payload.

  "! Create a group resource
  "! @parameter payload | Group resource to be created
  "! @parameter group | Created group resource
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS create_group
    IMPORTING
      payload      TYPE ts_group
    RETURNING
      VALUE(group) TYPE ts_group
    RAISING
      zcx_sap_ids_scim_api.

  "! Retrieves a specific group
  "! @parameter id | Group ID
  "! @parameter attributes | A multi-valued list that indicates attributes names in standard notation to return in the response
  "! @parameter excludedAttributes | A multi-valued list that indicates attributes names in standard notation to exclude from the response
  "! @parameter group | Retrieved group resource
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS get_group
    IMPORTING
      id                  TYPE string
      attributes          TYPE string OPTIONAL
      excluded_attributes TYPE string OPTIONAL
    RETURNING
      VALUE(group)        TYPE ts_group
    RAISING
      zcx_sap_ids_scim_api.

  "! Updates all attributes of a group
  "! @parameter group | Group resource to be updated
  "! @raising zcx_sap_ids_scim_api | SCIM API Errors
  METHODS update_group
    IMPORTING
      group TYPE ts_group
    RAISING
      zcx_sap_ids_scim_api.

  "! Deletes a specific group
  "! @parameter id | Group ID to be deleted
  "! @raising zcx_sap_ids_scim_api | SCIM API Errors
  METHODS delete_group
    IMPORTING
      id TYPE string
    RAISING
      zcx_sap_ids_scim_api.

  "! Retrieves a list of groups based on the provided filter criteria
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS search_groups
    IMPORTING
      count         TYPE i OPTIONAL
      start_index   TYPE i OPTIONAL
    RETURNING
      VALUE(groups) TYPE ts_groups
    RAISING
      zcx_sap_ids_scim_api.

  "! Add a group member
  "! @parameter group_id | Group ID
  "! @parameter user_id  | User ID to be added to the group
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS add_group_member
    IMPORTING
      group_id TYPE string
      user_id  TYPE string
    RAISING
      zcx_sap_ids_scim_api.

  "! Add group members
  "! @parameter group_id | Group ID
  "! @parameter user_ids | User IDs to be added to the group
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS add_group_members
    IMPORTING
      group_id  TYPE string
      user_ids  TYPE tt_op_member
    RAISING
      zcx_sap_ids_scim_api.

  "! Remove a group member
  "! @parameter group_id | Group ID
  "! @parameter user_id  | User ID to be removed from the group
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS remove_group_member
    IMPORTING
      group_id TYPE string
      user_id  TYPE string
    RAISING
      zcx_sap_ids_scim_api.

ENDINTERFACE.
