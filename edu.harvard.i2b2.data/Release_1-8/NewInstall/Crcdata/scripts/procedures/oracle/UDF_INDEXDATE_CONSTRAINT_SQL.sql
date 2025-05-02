create or replace FUNCTION udf_indexdate_constraint_sql (
    p_TABLE_INSTANCE_ID                  IN NUMBER,
    p_CONSTRAIN_BY_INDEXDATE_COLUMNNAME IN VARCHAR2,
    p_CONSTRAIN_BY_INDEXDATE_FROM_DAYS  IN NUMBER DEFAULT -99999,
    p_CONSTRAIN_BY_INDEXDATE_TO_DAYS    IN NUMBER DEFAULT 99999
) RETURN CLOB
IS
    v_indexdate_sql         CLOB := '';
    v_indexdatecol_sql      CLOB;

    -- Metadata variables
    v_COLUMN_NAME                         VARCHAR2(1000);
    v_C_TABLENAME                         VARCHAR2(50);
    v_C_COLUMNNAME                        VARCHAR2(30);
    v_C_COLUMNDATATYPE                    VARCHAR2(50);
    v_C_DIMCODE                           VARCHAR2(1000);
    v_C_OPERATOR                          VARCHAR2(30);
    v_C_FACTTABLECOLUMN                   VARCHAR2(100);
    v_CONSTRAIN_BY_DATE_TO                VARCHAR2(100);
    v_CONSTRAIN_BY_DATE_FROM              VARCHAR2(100);
    v_CONSTRAIN_BY_VALUE_OPERATOR         VARCHAR2(20);
    v_CONSTRAIN_BY_VALUE_CONSTRAINT       VARCHAR2(1000);
    v_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE VARCHAR2(50);
    v_CONSTRAIN_BY_VALUE_TYPE             VARCHAR2(50);
    v_AGG_TYPE                            VARCHAR2(50);
BEGIN
    -- Fetch metadata for the index date column
    SELECT
        COLUMN_NAME,
        AGG_TYPE,
        CONSTRAIN_BY_DATE_TO,
        CONSTRAIN_BY_DATE_FROM,
        CONSTRAIN_BY_VALUE_OPERATOR,
        CONSTRAIN_BY_VALUE_CONSTRAINT,
        CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
        CONSTRAIN_BY_VALUE_TYPE,
        C_TABLENAME,
        C_FACTTABLECOLUMN,
        C_COLUMNNAME,
        C_COLUMNDATATYPE,
        C_DIMCODE,
        C_OPERATOR
    INTO
        v_COLUMN_NAME,
        v_AGG_TYPE,
        v_CONSTRAIN_BY_DATE_TO,
        v_CONSTRAIN_BY_DATE_FROM,
        v_CONSTRAIN_BY_VALUE_OPERATOR,
        v_CONSTRAIN_BY_VALUE_CONSTRAINT,
        v_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
        v_CONSTRAIN_BY_VALUE_TYPE,
        v_C_TABLENAME,
        v_C_FACTTABLECOLUMN,
        v_C_COLUMNNAME,
        v_C_COLUMNDATATYPE,
        v_C_DIMCODE,
        v_C_OPERATOR
    FROM RPDO_TABLE_REQUEST
    WHERE TABLE_INSTANCE_ID = p_TABLE_INSTANCE_ID
      AND COLUMN_NAME = p_CONSTRAIN_BY_INDEXDATE_COLUMNNAME;

    -- Call the column SQL function to generate the inner query
    v_indexdatecol_sql := udf_rpdo_column_sql_index(
        p_COLUMN_NAME                         => v_COLUMN_NAME,
        p_C_FACTTABLECOLUMN                   => v_C_FACTTABLECOLUMN,
        p_C_TABLENAME                         => v_C_TABLENAME,
        p_C_COLUMNNAME                        => v_C_COLUMNNAME,
        p_C_COLUMNDATATYPE                    => v_C_COLUMNDATATYPE,
        p_C_DIMCODE                           => v_C_DIMCODE,
        p_C_OPERATOR                          => v_C_OPERATOR,
        p_CONSTRAIN_BY_DATE_TO                => v_CONSTRAIN_BY_DATE_TO,
        p_CONSTRAIN_BY_DATE_FROM              => v_CONSTRAIN_BY_DATE_FROM,
        p_CONSTRAIN_BY_VALUE_OPERATOR         => v_CONSTRAIN_BY_VALUE_OPERATOR,
        p_CONSTRAIN_BY_VALUE_CONSTRAINT       => v_CONSTRAIN_BY_VALUE_CONSTRAINT,
        p_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE => v_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
        p_CONSTRAIN_BY_VALUE_TYPE             => v_CONSTRAIN_BY_VALUE_TYPE,
        p_AGG_TYPE                            => v_AGG_TYPE,
        p_TABLE_INSTANCE_ID                   => p_TABLE_INSTANCE_ID
    );

    -- Final index date SQL constraint
    v_indexdate_sql :=
        ' AND EXISTS (SELECT 1 FROM (' || v_indexdatecol_sql || ') t1 ' ||
        'WHERE f.patient_num = t1.patient_num ' ||
        'AND (f.start_date - TO_DATE(t1.val)) BETWEEN ' ||
        TO_CHAR(p_CONSTRAIN_BY_INDEXDATE_FROM_DAYS) || ' AND ' ||
        TO_CHAR(p_CONSTRAIN_BY_INDEXDATE_TO_DAYS) || ')';

    RETURN v_indexdate_sql;
END;
/

