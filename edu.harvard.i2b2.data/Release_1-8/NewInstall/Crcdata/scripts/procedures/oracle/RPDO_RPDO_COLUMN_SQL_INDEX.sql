create or replace FUNCTION udf_rpdo_column_sql_index (
    p_PATIENTSET_SQL                   CLOB DEFAULT 'SELECT patient_num FROM patient_dimension',
    p_COLUMN_NAME                      VARCHAR2,
    p_C_FACTTABLECOLUMN                VARCHAR2,
    p_C_TABLENAME                      VARCHAR2,
    p_C_COLUMNNAME                     VARCHAR2,
    p_C_COLUMNDATATYPE                 VARCHAR2,
    p_C_DIMCODE                        VARCHAR2,
    p_C_OPERATOR                       VARCHAR2,
    p_CONSTRAIN_BY_DATE_TO            VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_DATE_FROM          VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_OPERATOR     VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_CONSTRAINT   VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_TYPE         VARCHAR2 DEFAULT NULL,
    p_AGG_TYPE                        VARCHAR2,
    p_TABLE_INSTANCE_ID               NUMBER,
    p_CONSTRAIN_BY_INDEXDATE_COLUMNNAME VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_INDEXDATE_FROM_DAYS  NUMBER DEFAULT NULL,
    p_CONSTRAIN_BY_INDEXDATE_TO_DAYS    NUMBER DEFAULT NULL
) RETURN CLOB
AS
    v_rpdo_column_sql        CLOB;
    v_constraint_sql         CLOB;
    v_indexdate_constraint_sql CLOB := '';
    v_ontology_constraint_sql CLOB;
    v_aggregation_sql        CLOB;
    v_C_FACTTABLE            VARCHAR2(100) := 'observation_fact';
    v_fact_column            VARCHAR2(100);
BEGIN
    IF p_C_TABLENAME = 'patient_dimension' AND p_AGG_TYPE = 'Value' THEN
        v_rpdo_column_sql := 'SELECT patient_num, ''' || p_COLUMN_NAME || ''' col, ' ||
                             'TO_CHAR(' || p_C_FACTTABLECOLUMN || ', ''YYYY-MM-DD'') val ' ||
                             'FROM patient_dimension ' ||
                             'WHERE patient_num IN (' || p_PATIENTSET_SQL || ')';
    ELSE
        -- Get supporting SQL parts
        v_constraint_sql := udf_constraint_sql(
            p_C_TABLENAME,
            p_CONSTRAIN_BY_DATE_FROM,
            p_CONSTRAIN_BY_DATE_TO,
            p_CONSTRAIN_BY_VALUE_OPERATOR,
            p_CONSTRAIN_BY_VALUE_CONSTRAINT,
            p_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
            p_CONSTRAIN_BY_VALUE_TYPE
        );

        v_ontology_constraint_sql := udf_constraint_ontology_sql(
            p_C_OPERATOR,
            p_C_COLUMNNAME,
            p_C_COLUMNDATATYPE,
            p_C_DIMCODE
        );

        v_aggregation_sql := udf_aggregation_sql(p_AGG_TYPE);

        -- Parse fact table from column
        IF INSTR(p_C_FACTTABLECOLUMN, '.') > 0 THEN
            v_C_FACTTABLE := SUBSTR(p_C_FACTTABLECOLUMN, 1, INSTR(p_C_FACTTABLECOLUMN, '.') - 1);
            v_fact_column := SUBSTR(p_C_FACTTABLECOLUMN, INSTR(p_C_FACTTABLECOLUMN, '.') + 1);
        ELSE
            v_fact_column := p_C_FACTTABLECOLUMN;
        END IF;

        -- Build base query
        v_rpdo_column_sql := 'SELECT DISTINCT patient_num, ' ||
                             REPLACE(v_aggregation_sql, 'FROM t GROUP BY patient_num', '') ||
                             ' FROM (';

        v_rpdo_column_sql := v_rpdo_column_sql ||
                             'SELECT DISTINCT patient_num, start_date';

        IF p_C_TABLENAME = 'visit_dimension' THEN
            v_rpdo_column_sql := v_rpdo_column_sql || ', encounter_num, ' || v_fact_column;
        ELSIF p_C_TABLENAME = 'concept_dimension' THEN
            v_rpdo_column_sql := v_rpdo_column_sql || ', ' || v_fact_column;
        END IF;

        v_rpdo_column_sql := v_rpdo_column_sql || ' FROM ' || v_C_FACTTABLE || ' f ' ||
                             'WHERE patient_num IN (' || p_PATIENTSET_SQL || ') ' ||
                             'AND f.' || v_fact_column || ' IN (' ||
                             'SELECT ' || v_fact_column || ' FROM ' || p_C_TABLENAME ||
                             ' WHERE ' || v_ontology_constraint_sql || ') ' ||
                             v_constraint_sql || ') t GROUP BY patient_num';
    END IF;

    RETURN v_rpdo_column_sql;
END;


