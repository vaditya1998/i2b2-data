create or replace FUNCTION udf_rpdo_column_sql (
    p_PATIENTSET_SQL                    IN CLOB,
    p_COLUMN_NAME                       IN VARCHAR2,
    p_C_FACTTABLECOLUMN                 IN VARCHAR2,
    p_C_TABLENAME                       IN VARCHAR2,
    p_C_COLUMNNAME                      IN VARCHAR2,
    p_C_COLUMNDATATYPE                  IN VARCHAR2,
    p_C_DIMCODE                         IN VARCHAR2,
    p_C_OPERATOR                        IN VARCHAR2,
    p_CONSTRAIN_BY_DATE_TO              IN VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_DATE_FROM            IN VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_OPERATOR       IN VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_CONSTRAINT     IN VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE IN VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_VALUE_TYPE           IN VARCHAR2 DEFAULT NULL,
    p_AGG_TYPE                          IN VARCHAR2,
    p_TABLE_INSTANCE_ID                 IN NUMBER,
    p_CONSTRAIN_BY_INDEXDATE_COLUMNNAME IN VARCHAR2 DEFAULT NULL,
    p_CONSTRAIN_BY_INDEXDATE_FROM_DAYS  IN NUMBER DEFAULT NULL,
    p_CONSTRAIN_BY_INDEXDATE_TO_DAYS    IN NUMBER DEFAULT NULL
) RETURN CLOB
IS
    v_rpdo_column_sql      CLOB := '';
    v_constraint_sql       CLOB := '';
    v_indexdate_constraint_sql CLOB := '';
    v_ontology_constraint_sql  CLOB := '';
    v_aggregation_sql      CLOB := '';
    v_facttable            VARCHAR2(100) := 'observation_fact';
    v_facttablecolumn      VARCHAR2(100) := p_C_FACTTABLECOLUMN;
    v_operator             VARCHAR2(30) := NVL(TRIM(p_C_OPERATOR), '=');
BEGIN
    DBMS_OUTPUT.PUT_LINE('>>> udf_rpdo_column_sql called with AGG_TYPE=' || NVL(p_AGG_TYPE, '<NULL>'));

    IF p_C_TABLENAME IS NULL OR TRIM(p_C_TABLENAME) IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('>>> Skipping due to missing C_TABLENAME');
        RETURN '';
    END IF;

    IF INSTR(v_facttablecolumn, '.') > 0 THEN
        v_facttable := SUBSTR(v_facttablecolumn, 1, INSTR(v_facttablecolumn, '.') - 1);
        v_facttablecolumn := SUBSTR(v_facttablecolumn, INSTR(v_facttablecolumn, '.') + 1);
    END IF;

    BEGIN
        v_constraint_sql := udf_constraint_sql(
            p_C_TABLENAME,
            p_CONSTRAIN_BY_DATE_FROM,
            p_CONSTRAIN_BY_DATE_TO,
            p_CONSTRAIN_BY_VALUE_OPERATOR,
            p_CONSTRAIN_BY_VALUE_CONSTRAINT,
            p_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
            p_CONSTRAIN_BY_VALUE_TYPE
        );
    EXCEPTION WHEN OTHERS THEN
        v_constraint_sql := '';
        DBMS_OUTPUT.PUT_LINE('>>> Error calling udf_constraint_sql: ' || SQLERRM);
    END;

    BEGIN
        IF p_C_COLUMNNAME IS NULL OR TRIM(p_C_COLUMNNAME) IS NULL OR p_C_DIMCODE IS NULL OR TRIM(p_C_DIMCODE) IS NULL THEN
            v_ontology_constraint_sql := '1=1';
        ELSE
            v_ontology_constraint_sql := udf_constraint_ontology_sql(
                v_operator,
                p_C_COLUMNNAME,
                p_C_COLUMNDATATYPE,
                p_C_DIMCODE
            );
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_ontology_constraint_sql := '1=1';
        DBMS_OUTPUT.PUT_LINE('>>> Error calling udf_constraint_ontology_sql: ' || SQLERRM);
    END;

    BEGIN
        v_aggregation_sql := udf_aggregation_sql(p_AGG_TYPE);
    EXCEPTION WHEN OTHERS THEN
        v_aggregation_sql := '''<no‑agg>'' val from t';
        DBMS_OUTPUT.PUT_LINE('>>> Error calling udf_aggregation_sql: ' || SQLERRM);
    END;

    IF p_CONSTRAIN_BY_INDEXDATE_COLUMNNAME IS NOT NULL THEN
        BEGIN
            v_indexdate_constraint_sql := udf_indexdate_constraint_sql(
                p_TABLE_INSTANCE_ID,
                p_CONSTRAIN_BY_INDEXDATE_COLUMNNAME,
                p_CONSTRAIN_BY_INDEXDATE_FROM_DAYS,
                p_CONSTRAIN_BY_INDEXDATE_TO_DAYS
            );
        EXCEPTION WHEN OTHERS THEN
            v_indexdate_constraint_sql := '';
            DBMS_OUTPUT.PUT_LINE('>>> Error calling udf_indexdate_constraint_sql: ' || SQLERRM);
        END;
    END IF;

    -- ✨ Major Fix: Correct datatype formatting
    IF p_C_TABLENAME = 'patient_dimension' AND p_AGG_TYPE = 'Value' THEN
        IF p_C_COLUMNDATATYPE IN ('D') THEN
            -- It's a date field
            v_rpdo_column_sql := 'SELECT patient_num, ''' || p_COLUMN_NAME || ''' AS col, ' ||
                                 'TO_CHAR(' || v_facttablecolumn || ', ''YYYY-MM-DD'') AS val ' ||
                                 'FROM patient_dimension ' ||
                                 'WHERE patient_num IN (' || p_PATIENTSET_SQL || ')';
        ELSIF p_C_COLUMNDATATYPE IN ('N') THEN
            -- It's a number field, no TO_CHAR
            v_rpdo_column_sql := 'SELECT patient_num, ''' || p_COLUMN_NAME || ''' AS col, ' ||
                                 v_facttablecolumn || ' AS val ' ||
                                 'FROM patient_dimension ' ||
                                 'WHERE patient_num IN (' || p_PATIENTSET_SQL || ')';
        ELSE
            -- Treat as varchar/text field
            v_rpdo_column_sql := 'SELECT patient_num, ''' || p_COLUMN_NAME || ''' AS col, ' ||
                                 'TO_CHAR(' || v_facttablecolumn || ') AS val ' ||
                                 'FROM patient_dimension ' ||
                                 'WHERE patient_num IN (' || p_PATIENTSET_SQL || ')';
        END IF;
    ELSIF p_C_TABLENAME = 'qt_patient_set_collection' AND p_AGG_TYPE = 'Exists' THEN
        v_rpdo_column_sql := 'SELECT patient_num, ''' || p_COLUMN_NAME || ''' AS col, ''Yes'' AS val ' ||
                             'FROM qt_patient_set_collection ' ||
                             'WHERE result_instance_id = ' || p_C_DIMCODE || ' ' ||
                             'AND patient_num IN (' || p_PATIENTSET_SQL || ')';

    ELSIF p_AGG_TYPE IN ('MinDate','MaxDate') THEN
		v_rpdo_column_sql :=
		  'WITH t AS ( '||
			'SELECT patient_num, START_DATE '||
			'FROM '||v_facttable||' f '||
			'WHERE patient_num IN ('||p_PATIENTSET_SQL||') '||
			'  AND f.'||v_facttablecolumn||' IN ( '||
			  'SELECT '||v_facttablecolumn||' FROM '||p_C_TABLENAME||
			  ' WHERE '||v_ontology_constraint_sql||
			')'||
			v_constraint_sql||v_indexdate_constraint_sql||
		  ') '||
		  'SELECT DISTINCT '||
			'patient_num, '||
			'''' || p_COLUMN_NAME || ''' AS col, '||
			'TO_CHAR('||
			  CASE p_AGG_TYPE
				WHEN 'MinDate' THEN 'MIN(START_DATE)'
				ELSE               'MAX(START_DATE)'
			  END ||
			', ''YYYY-MM-DD'') AS val '||
		  'FROM t '||
		  'GROUP BY patient_num';
      
    ELSIF p_AGG_TYPE IN ( 
     'NumEncounters',
     'NumConcepts',
     'NumDates',
     'NumProviders',
     'NumFacts'
   )
	THEN
	  v_rpdo_column_sql :=
		'WITH t AS ( '||
		  'SELECT DISTINCT patient_num, encounter_num, concept_cd, start_date, provider_id, tval_char, nval_num '||
		  'FROM ' || v_facttable || ' f '||
		  'WHERE patient_num IN ('||p_PATIENTSET_SQL||') '||
		  '  AND f.'||v_facttablecolumn||' IN ( '||
			   'SELECT '||v_facttablecolumn||' FROM '||p_C_TABLENAME||
			   ' WHERE '||v_ontology_constraint_sql||') '||
		  v_constraint_sql||v_indexdate_constraint_sql||
		') '||
		'SELECT patient_num, '||
		  '''' || p_COLUMN_NAME || ''' AS col, '||
		  v_aggregation_sql || ' ';

    ELSE
        -- Normal table handling
        v_rpdo_column_sql := 'WITH t AS (SELECT DISTINCT patient_num, encounter_num, concept_cd, start_date, provider_id, tval_char, nval_num ' ||
                             'FROM ' || v_facttable || ' f ' ||
                             'WHERE patient_num IN (' || p_PATIENTSET_SQL || ') ' ||
                             'AND f.' || v_facttablecolumn || ' IN (SELECT ' || v_facttablecolumn || ' FROM ' || p_C_TABLENAME ||
                             ' WHERE ' || v_ontology_constraint_sql || ') ' ||
                             v_constraint_sql || v_indexdate_constraint_sql || ') ' ||
                             'SELECT DISTINCT patient_num, ''' || REPLACE(p_COLUMN_NAME, '''', '''''') || ''' AS col, ' || v_aggregation_sql || '';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Generated SQL: ' || v_rpdo_column_sql);

    RETURN v_rpdo_column_sql;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('>>> NO DATA FOUND in udf_rpdo_column_sql');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in udf_rpdo_column_sql: ' || SQLERRM);
        RETURN NULL;
END;
/

