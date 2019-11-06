class ZCL_CUTE_APACK definition
  public
  final
  create public .

public section.

  interfaces ZIF_APACK_MANIFEST .

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CUTE_APACK IMPLEMENTATION.


  METHOD constructor.

    zif_apack_manifest~descriptor-group_id        = 'tricktresor.de'.
    zif_apack_manifest~descriptor-artifact_id     = 'cute'.
    zif_apack_manifest~descriptor-version         = '0.1.1'.
    zif_apack_manifest~descriptor-git_url         = 'https://github.com/tricktresor/cute'.
    zif_apack_manifest~descriptor-dependencies    = VALUE #(
      ( group_id    = 'tricktresor.de'
        artifact_id = 'dodo'
        git_url     = 'https://github.com/tricktresor/dodo' ) ).
    zif_apack_manifest~descriptor-repository_type = ``.

  ENDMETHOD.
ENDCLASS.
