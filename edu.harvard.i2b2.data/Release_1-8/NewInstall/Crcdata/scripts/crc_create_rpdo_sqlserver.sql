
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
    CONSTRAIN_BY_DATE_TO               datetime,
    CONSTRAIN_BY_DATE_FROM             datetime,
    CONSTRAIN_BY_VALUE_OPERATOR        varchar(20),
    CONSTRAIN_BY_VALUE_CONSTRAINT      varchar(1000),
    CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE varchar(50),
    CONSTRAIN_BY_VALUE_TYPE            varchar(50),
    CREATE_DATE                        datetime     not null,
    DELETE_DATE                        datetime,
    UPDATE_DATE                        datetime,
    DELETE_FLAG                        varchar(3),
    GENERATED_SQL                      varchar(max),
    JSON_DATA                          varchar(max),
    CONSTRAIN_BY_INDEXDATE_COLUMNNAME  varchar(1000),
    CONSTRAIN_BY_INDEXDATE_FROM_DAYS   int,
    CONSTRAIN_BY_INDEXDATE_TO_DAYS     int,
    USE_AS_COHORT                      char
)
go


create table RPDO_LOG
(
    LOGGED varchar(max)
)
go


