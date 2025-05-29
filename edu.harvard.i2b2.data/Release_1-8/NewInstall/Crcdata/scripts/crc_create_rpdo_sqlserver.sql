create table RPDO_TABLE_REQUEST
(
    TABLE_REQUEST_ID                   int identity,
    TABLE_INSTANCE_ID                  int          not null,
    TABLE_INSTANCE_NAME                varchar(250) not null,
    USER_ID                            varchar(50)  not null,
    GROUP_ID                           varchar(50)  not null,
    SET_INDEX                          int          not null,
    C_FACTTABLECOLUMN                  varchar(50)  not null,
    C_TABLENAME                        varchar(100) not null,
    COLUMN_NAME                        varchar(1000),
    C_FULLPATH                         varchar(700),
    C_COLUMNNAME                       varchar(30),
    C_COLUMNDATATYPE                   varchar(50),
    C_OPERATOR                         varchar(30),
    C_DIMCODE                          varchar(1000),
    AGG_TYPE                           varchar(50)  not null,
    CONSTRAIN_BY_DATE_TO               date,
    CONSTRAIN_BY_DATE_FROM             date,
    CONSTRAIN_BY_VALUE_OPERATOR        varchar(20),
    CONSTRAIN_BY_VALUE_CONSTRAINT      varchar(1000),
    CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE varchar(50),
    CONSTRAIN_BY_VALUE_TYPE            varchar(50),
    CREATE_DATE                        datetime,
    DELETE_DATE                        datetime,
    UPDATE_DATE                        datetime,
    DELETE_FLAG                        varchar(3),
    GENERATED_SQL                      varchar(max),
    JSON_DATA                          varchar(max),
    CONSTRAIN_BY_INDEXDATE_COLUMNNAME  varchar(1000),
    CONSTRAIN_BY_INDEXDATE_FROM_DAYS   int,
    CONSTRAIN_BY_INDEXDATE_TO_DAYS     int,
    USE_AS_COHORT                      char,
    REQUIRED                           varchar(3),
    SHARED                             char
);


create table RPDO_LOG
(
    LOGGED varchar(max)
);

INSERT INTO RPDO_TABLE_REQUEST (TABLE_INSTANCE_ID, TABLE_INSTANCE_NAME, USER_ID, GROUP_ID, SET_INDEX, C_FACTTABLECOLUMN, C_TABLENAME, COLUMN_NAME, C_FULLPATH, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, AGG_TYPE, CONSTRAIN_BY_DATE_TO, CONSTRAIN_BY_DATE_FROM, CONSTRAIN_BY_VALUE_OPERATOR, CONSTRAIN_BY_VALUE_CONSTRAINT, CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE, CONSTRAIN_BY_VALUE_TYPE, CREATE_DATE, DELETE_DATE, UPDATE_DATE, DELETE_FLAG, GENERATED_SQL, JSON_DATA, CONSTRAIN_BY_INDEXDATE_COLUMNNAME, CONSTRAIN_BY_INDEXDATE_FROM_DAYS, CONSTRAIN_BY_INDEXDATE_TO_DAYS, USE_AS_COHORT, REQUIRED, SHARED) VALUES (-1, 'Default Required', '@', '@', 1, 'sex_cd', 'patient_dimension', 'Gender', ' @', ' @', '@', ' @', ' @', 'Value', null, null, null, null, null, null, null, null, null, '', null, '[{"dataOption":"Value","index":1,"sdxData":{"renderData":{"title":"Gender"}}}]', null, null, null, '', 'Y', null)
;
INSERT INTO RPDO_TABLE_REQUEST (TABLE_INSTANCE_ID, TABLE_INSTANCE_NAME, USER_ID, GROUP_ID, SET_INDEX, C_FACTTABLECOLUMN, C_TABLENAME, COLUMN_NAME, C_FULLPATH, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, AGG_TYPE, CONSTRAIN_BY_DATE_TO, CONSTRAIN_BY_DATE_FROM, CONSTRAIN_BY_VALUE_OPERATOR, CONSTRAIN_BY_VALUE_CONSTRAINT, CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE, CONSTRAIN_BY_VALUE_TYPE, CREATE_DATE, DELETE_DATE, UPDATE_DATE, DELETE_FLAG, GENERATED_SQL, JSON_DATA, CONSTRAIN_BY_INDEXDATE_COLUMNNAME, CONSTRAIN_BY_INDEXDATE_FROM_DAYS, CONSTRAIN_BY_INDEXDATE_TO_DAYS, USE_AS_COHORT, REQUIRED, SHARED) VALUES (-1, 'Default Required', '@', '@', 2, 'age_in_years_num', 'patient_dimension', 'Age', ' @', ' @', '@', ' @', ' @', 'Value', null, null, null, null, null, null, null, null, null, '', null, '[{"dataOption":"Value","index":2,"sdxData":{"renderData":{"title":"Age"}}}]', null, null, null, '', 'Y', null)
;
INSERT INTO RPDO_TABLE_REQUEST (TABLE_INSTANCE_ID, TABLE_INSTANCE_NAME, USER_ID, GROUP_ID, SET_INDEX, C_FACTTABLECOLUMN, C_TABLENAME, COLUMN_NAME, C_FULLPATH, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR, C_DIMCODE, AGG_TYPE, CONSTRAIN_BY_DATE_TO, CONSTRAIN_BY_DATE_FROM, CONSTRAIN_BY_VALUE_OPERATOR, CONSTRAIN_BY_VALUE_CONSTRAINT, CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE, CONSTRAIN_BY_VALUE_TYPE, CREATE_DATE, DELETE_DATE, UPDATE_DATE, DELETE_FLAG, GENERATED_SQL, JSON_DATA, CONSTRAIN_BY_INDEXDATE_COLUMNNAME, CONSTRAIN_BY_INDEXDATE_FROM_DAYS, CONSTRAIN_BY_INDEXDATE_TO_DAYS, USE_AS_COHORT, REQUIRED, SHARED) VALUES (-1, 'Default Required', '@', '@', 3, 'race_cd', 'patient_dimension', 'Race', ' @', ' @', '@', ' @', ' @', 'Value', null, null, null, null, null, null, null, null, null, '', null, '[{"dataOption":"Value","index":3,"sdxData":{"renderData":{"title":"Race"}}}]', null, null, null, '', 'Y', null)
;


