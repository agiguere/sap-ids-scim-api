INTERFACE zif_sap_ids_scim_user_api
  PUBLIC .

  CONSTANTS: BEGIN OF custom_extension,
               json_name TYPE string VALUE 'urn:sap:cloud:scim:schemas:extension:custom:2.0:User',
               abap_name TYPE string VALUE 'customExt',
             END   OF custom_extension.

  CONSTANTS: BEGIN OF enterprise_extension,
               json_name TYPE string VALUE 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
               abap_name TYPE string VALUE 'enterpriseExt',
             END   OF enterprise_extension.

  CONSTANTS: BEGIN OF core_extension,
               json_name TYPE string VALUE 'urn:ietf:params:scim:schemas:core:2.0:User',
               abap_name TYPE string VALUE 'coreExt',
             END   OF core_extension.

  CONSTANTS: BEGIN OF sap_extension,
               json_name TYPE string VALUE 'urn:ietf:params:scim:schemas:extension:sap:2.0:User',
               abap_name TYPE string VALUE 'sapExt',
             END   OF sap_extension.

  TYPES: BEGIN OF ts_custom_attribute,
           name  TYPE string,
           value TYPE string,
         END   OF ts_custom_attribute.

  TYPES: BEGIN OF ts_custom_extension,
           attributes TYPE STANDARD TABLE OF ts_custom_attribute WITH DEFAULT KEY,
         END   OF ts_custom_extension.

  TYPES: BEGIN OF ts_terms_of_use,
           time_of_acceptance TYPE string,
           name               TYPE string,
           id                 TYPE string,
           locale             TYPE string,
           version            TYPE string,
         END   OF ts_terms_of_use.

  TYPES: BEGIN OF ts_privacy_policy,
           time_of_acceptance TYPE string,
           name               TYPE string,
           id                 TYPE string,
           locale             TYPE string,
           version            TYPE string,
         END   OF ts_privacy_policy.

  TYPES: BEGIN OF ts_phone_number,
           value   TYPE string,
           type    TYPE string,
           primary TYPE abap_bool,
         END   OF ts_phone_number.

  TYPES: BEGIN OF ts_meta,
           created       TYPE string,
           last_modified TYPE string,
           location      TYPE string,
           resource_type TYPE string,
           version       TYPE string,
         END   OF ts_meta.

  TYPES: BEGIN OF ts_group,
           value   TYPE string,
           display TYPE string,
           ref     TYPE string,
         END   OF ts_group.

  TYPES: BEGIN OF ts_update_group,
           value TYPE string,
         END   OF ts_update_group.

  TYPES: BEGIN OF ts_manager,
           display_name TYPE string,
           value        TYPE string,
           ref          TYPE string,
         END   OF ts_manager.

  TYPES: BEGIN OF ts_employee_info,
           division        TYPE string,
           organization    TYPE string,
           department      TYPE string,
           employee_number TYPE string,
           cost_center     TYPE string,
           manager         TYPE ts_manager,
         END   OF ts_employee_info.

  TYPES: BEGIN OF ts_user_name,
           given_name       TYPE string,
           family_name      TYPE string,
           middle_name      TYPE string,
           formatted        TYPE string,
           honorific_prefix TYPE string,
           honorific_suffix TYPE string,
         END   OF ts_user_name.

  TYPES: BEGIN OF ts_address,
           street_address TYPE string,
           locality       TYPE string,
           region         TYPE string,
           postal_code    TYPE string,
           primary        TYPE abap_bool,
           country        TYPE string,
           type           TYPE string,
         END   OF ts_address.

  TYPES: BEGIN OF ts_company_info,
           company      TYPE string,
           department   TYPE string,
           industry_crm TYPE string,
         END   OF ts_company_info.

  TYPES: BEGIN OF ts_email,
           value   TYPE string,
           primary TYPE abap_bool,
         END   OF ts_email.

  TYPES: BEGIN OF ts_password_details,
           login_time            TYPE string,
           failed_login_attempts TYPE string,
           set_time              TYPE string,
           status                TYPE string,
           policy                TYPE string,
         END   OF ts_password_details.

  TYPES: BEGIN OF ts_sap_ext_email,
           verified      TYPE abap_bool,
           value         TYPE string,
           verified_time TYPE string,
           primary       TYPE abap_bool,
         END   OF ts_sap_ext_email.

  TYPES: BEGIN OF ts_core_extension,
           addresses TYPE STANDARD TABLE OF ts_address WITH DEFAULT KEY,
         END   OF ts_core_extension.

  TYPES: BEGIN OF ts_sap_extension,
           emails           TYPE STANDARD TABLE OF ts_sap_ext_email WITH DEFAULT KEY,
           addresses        TYPE STANDARD TABLE OF ts_address WITH DEFAULT KEY,
           source_system    TYPE string,
           user_uuid        TYPE string,
           mail_verified    TYPE abap_bool,
           send_mail        TYPE abap_bool,
           user_id          TYPE string,
           status           TYPE string,
           password_details TYPE ts_password_details,
         END   OF ts_sap_extension.

  TYPES: BEGIN OF ts_user,
           schemas            TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           id                 TYPE string,
           meta               TYPE ts_meta,
           user_name          TYPE string,
           password           TYPE string,
           name               TYPE ts_user_name,
           display_name       TYPE string,
           nick_name          TYPE string,
           profile_url        TYPE string,
           title	             TYPE string,
           user_type          TYPE string,
           preferred_language TYPE string,
           locale	            TYPE string,
           timezone           TYPE string,
           active             TYPE abap_bool,
           emails             TYPE STANDARD TABLE OF ts_email WITH DEFAULT KEY,
           phone_numbers      TYPE STANDARD TABLE OF ts_phone_number WITH DEFAULT KEY,
           groups             TYPE STANDARD TABLE OF ts_group WITH DEFAULT KEY,
           addresses          TYPE STANDARD TABLE OF ts_address WITH DEFAULT KEY,
           custom_ext         TYPE ts_custom_extension,
           sap_ext            TYPE ts_sap_extension,
         END   OF ts_user.

  TYPES: tt_user TYPE STANDARD TABLE OF ts_user.

  TYPES: BEGIN OF ts_users,
           schemas        TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           total_results  TYPE i,
           items_per_page TYPE i,
           start_index    TYPE i,
           start_id       TYPE string,
           next_id        TYPE string,
           next_cursor    TYPE string,
           resources      TYPE STANDARD TABLE OF ts_user WITH DEFAULT KEY,
         END   OF ts_users.

  "! Creates a user resource
  "! @parameter payload | User resource to be created
  "! @parameter user | Created user resource
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS create_user
    IMPORTING
      payload     TYPE ts_user
    RETURNING
      VALUE(user) TYPE ts_user
    RAISING
      zcx_sap_ids_scim_api.

  "! Retrieves a specific user by id.
  "! @parameter id | User ID to be retrieved
  "! @parameter user | Retrieved user resource
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS get_user
    IMPORTING
      id          TYPE string
    RETURNING
      VALUE(user) TYPE ts_user
    RAISING
      zcx_sap_ids_scim_api.

  "! Updates all attributes of a user
  "! @parameter user | User resource to be updated
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS update_user
    IMPORTING
      user TYPE ts_user
    RAISING
      zcx_sap_ids_scim_api.

  "! Updates specific attributes of a user
  "! @parameter id | User ID to be updated
  "! @parameter payload | User resource with attributes to be updated
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS patch_user
    IMPORTING
      id      TYPE string
      payload TYPE string
    RAISING
      zcx_sap_ids_scim_api.

  "! Deletes a specific user by id and all his membership assignments.
  "! @parameter id | User ID to be deleted
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS delete_user
    IMPORTING
      id TYPE string
    RAISING
      zcx_sap_ids_scim_api.

  "! Retrieves a list of users based on the provided filter criteria
  "! @parameter filter | Filter criteria
  "! @parameter users | Retrieved list of users
  "! @raising zcx_sap_ids_scim_api | SCIM API Error
  METHODS search_users
    IMPORTING
      filter       TYPE string OPTIONAL
    RETURNING
      VALUE(users) TYPE ts_users
    RAISING
      zcx_sap_ids_scim_api.

ENDINTERFACE.
