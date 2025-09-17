

-------------------------------------------------------------------------------
-- ACT_DEM_V42
-------------------------------------------------------------------------------


CREATE TABLE ACT_DEM_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_VISIT_DETAILS_V41
-------------------------------------------------------------------------------


CREATE TABLE ACT_VISIT_DETAILS_V41
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_ICD10_ICD9_DX_V4
-------------------------------------------------------------------------------



CREATE TABLE ACT_ICD10_ICD9_DX_V4
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_ICD10CM_DX_V42
-------------------------------------------------------------------------------


CREATE TABLE ACT_ICD10CM_DX_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_ICD10PCS_PX_V42
-------------------------------------------------------------------------------


CREATE TABLE ACT_ICD10PCS_PX_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_ICD9CM_DX_V4
-------------------------------------------------------------------------------

CREATE TABLE ACT_ICD9CM_DX_V4
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_ICD9CM_PX_V4
-------------------------------------------------------------------------------



CREATE TABLE ACT_ICD9CM_PX_V4
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_CPT4_PX_V42
-------------------------------------------------------------------------------

CREATE TABLE ACT_CPT4_PX_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_HCPCS_PX_V42
-------------------------------------------------------------------------------

CREATE TABLE ACT_HCPCS_PX_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_MED_ALPHA_V42
-------------------------------------------------------------------------------



CREATE TABLE ACT_MED_ALPHA_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_MED_VA_V42
-------------------------------------------------------------------------------

CREATE TABLE ACT_MED_VA_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_LOINC_LAB_V42
-------------------------------------------------------------------------------


CREATE TABLE ACT_LOINC_LAB_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_LOINC_LAB_PROV_V42
-------------------------------------------------------------------------------


CREATE TABLE ACT_LOINC_LAB_PROV_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_SDOH_V42
-------------------------------------------------------------------------------

CREATE TABLE ACT_SDOH_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_VITAL_SIGNS_V4
-------------------------------------------------------------------------------


CREATE TABLE ACT_VITAL_SIGNS_V4
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_COVID_V41
-------------------------------------------------------------------------------


CREATE TABLE ACT_COVID_V41
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_VAX_V42
-------------------------------------------------------------------------------




CREATE TABLE ACT_VAX_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_RESEARCH_V42
-------------------------------------------------------------------------------


CREATE TABLE ACT_RESEARCH_V42
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
-------------------------------------------------------------------------------
-- ACT_ZIPCODE_V41
-------------------------------------------------------------------------------



CREATE TABLE ACT_ZIPCODE_V41
(
  C_HLEVEL             NUMBER(10)       NOT NULL,
  C_FULLNAME           VARCHAR2(700 CHAR)   NOT NULL,
  C_NAME               VARCHAR2(2000 CHAR)  NOT NULL,
  C_SYNONYM_CD         CHAR(1 CHAR)     NOT NULL,
  C_VISUALATTRIBUTES   CHAR(3 CHAR)     NOT NULL,
  C_TOTALNUM           NUMBER(10),
  C_BASECODE           VARCHAR2(50 CHAR),
  C_METADATAXML        CLOB,
  C_FACTTABLECOLUMN    VARCHAR2(100 CHAR),
  C_TABLENAME          VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNNAME         VARCHAR2(50 CHAR)    NOT NULL,
  C_COLUMNDATATYPE     VARCHAR2(50 CHAR)    NOT NULL,
  C_OPERATOR           VARCHAR2(10 CHAR)    NOT NULL,
  C_DIMCODE            VARCHAR2(700 CHAR)   NOT NULL,
  C_COMMENT            CLOB,
  C_TOOLTIP            VARCHAR2(900 CHAR),
  M_APPLIED_PATH       VARCHAR2(700 CHAR)   NOT NULL,
  UPDATE_DATE          DATE,
  DOWNLOAD_DATE        DATE,
  IMPORT_DATE          DATE,
  SOURCESYSTEM_CD      VARCHAR2(50 CHAR),
  VALUETYPE_CD         VARCHAR2(50 CHAR),
  M_EXCLUSION_CD       VARCHAR2(25 CHAR),
  C_PATH               VARCHAR2(700 CHAR),
  C_SYMBOL             VARCHAR2(50 CHAR)
);
