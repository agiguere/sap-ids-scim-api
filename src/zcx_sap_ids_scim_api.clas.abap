CLASS zcx_sap_ids_scim_api DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF create_user_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr2 TYPE scx_attrname VALUE 'REASON',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF create_user_failed,

      BEGIN OF create_group_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr2 TYPE scx_attrname VALUE 'REASON',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF create_group_failed,

      BEGIN OF delete_user_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'USER_ID',
        attr2 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr3 TYPE scx_attrname VALUE 'REASON',
        attr4 TYPE scx_attrname VALUE '',
      END OF delete_user_failed,

      BEGIN OF delete_group_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '013',
        attr1 TYPE scx_attrname VALUE 'GROUP_ID',
        attr2 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr3 TYPE scx_attrname VALUE 'REASON',
        attr4 TYPE scx_attrname VALUE '',
      END OF delete_group_failed,

      BEGIN OF update_user_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'USER_ID',
        attr2 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr3 TYPE scx_attrname VALUE 'REASON',
        attr4 TYPE scx_attrname VALUE '',
      END OF update_user_failed,

      BEGIN OF update_group_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '012',
        attr1 TYPE scx_attrname VALUE 'GROUP_ID',
        attr2 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr3 TYPE scx_attrname VALUE 'REASON',
        attr4 TYPE scx_attrname VALUE '',
      END OF update_group_failed,

      BEGIN OF get_user_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'USER_ID',
        attr2 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr3 TYPE scx_attrname VALUE 'REASON',
        attr4 TYPE scx_attrname VALUE '',
      END OF get_user_failed,

      BEGIN OF get_group_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'GROUP_ID',
        attr2 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr3 TYPE scx_attrname VALUE 'REASON',
        attr4 TYPE scx_attrname VALUE '',
      END OF get_group_failed,

      BEGIN OF search_users_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr2 TYPE scx_attrname VALUE 'REASON',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF search_users_failed,

      BEGIN OF search_groups_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '014',
        attr1 TYPE scx_attrname VALUE 'STATUS_CODE',
        attr2 TYPE scx_attrname VALUE 'REASON',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF search_groups_failed,

      BEGIN OF create_connection_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF create_connection_failed,

      BEGIN OF close_connection_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF close_connection_failed,

      BEGIN OF send_request_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF send_request_failed,

      BEGIN OF receive_response_failed,
        msgid TYPE symsgid VALUE 'ZSAP_IDS_SCIM',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF receive_response_failed.

    DATA user_id TYPE string.
    DATA group_id TYPE string.
    DATA status_code TYPE i.
    DATA reason TYPE string.

    METHODS constructor
      IMPORTING
        !textid      LIKE if_t100_message=>t100key OPTIONAL
        !previous    LIKE previous OPTIONAL
        !user_id     TYPE string OPTIONAL
        !group_id    TYPE string OPTIONAL
        !status_code TYPE i OPTIONAL
        !reason      TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcx_sap_ids_scim_api IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    CLEAR me->textid.

    me->status_code = status_code.
    me->reason = reason.
    me->user_id = user_id.
    me->group_id = group_id.

    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
