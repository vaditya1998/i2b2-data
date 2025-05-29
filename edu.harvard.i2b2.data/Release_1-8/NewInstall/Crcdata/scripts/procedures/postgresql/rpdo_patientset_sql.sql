CREATE OR REPLACE FUNCTION udf_patientset_sql_dev(
    p_result_instance_id INTEGER DEFAULT NULL,
    p_min_row            INTEGER DEFAULT NULL,
    p_max_row            INTEGER DEFAULT NULL,
    p_table_instance_id  INTEGER DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    v_patientset_sql TEXT := '';
BEGIN
    IF p_result_instance_id IS NULL THEN
        v_patientset_sql :=
           'SELECT PATIENT_NUM FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (ORDER BY PATIENT_NUM) AS SET_INDEX FROM PATIENT_DIMENSION) x WHERE 1=1';
    ELSIF p_result_instance_id > 0 THEN
        v_patientset_sql :=
           'SELECT PATIENT_NUM FROM QT_PATIENT_SET_COLLECTION WHERE RESULT_INSTANCE_ID = ' || p_result_instance_id::TEXT;
    ELSIF p_result_instance_id = -1 THEN
        DECLARE
            rec RECORD;
            v_current_patientset_sql TEXT;
            v_constraint_sql TEXT;
            v_ontology_constraint_sql TEXT;
            v_c_tablename TEXT;
            v_constrain_by_date_to TEXT;
            v_constrain_by_date_from TEXT;
            v_constrain_by_value_operator TEXT;
            v_constrain_by_value_constraint TEXT;
            v_constrain_by_value_unit_of_measure TEXT;
            v_constrain_by_value_type TEXT;
            v_c_columnname TEXT;
            v_c_columndatatype TEXT;
            v_c_dimcode TEXT;
            v_c_operator TEXT;
            v_c_facttablecolumn TEXT;
            v_c_facttable TEXT := 'observation_fact';
            v_union TEXT := '';
        BEGIN
            FOR rec IN
              SELECT c_facttablecolumn,
                     c_tablename,
                     c_columnname,
                     c_columndatatype,
                     c_operator,
                     c_dimcode,
                     CONSTRAIN_BY_DATE_TO,
                     CONSTRAIN_BY_DATE_FROM,
                     CONSTRAIN_BY_VALUE_OPERATOR,
                     CONSTRAIN_BY_VALUE_CONSTRAINT,
                     CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
                     CONSTRAIN_BY_VALUE_TYPE,
                     ROW_NUMBER() OVER (ORDER BY SET_INDEX) AS cohort_index
              FROM RPDO_TABLE_REQUEST
              WHERE USE_AS_COHORT = 'Y'
                AND TABLE_INSTANCE_ID = p_table_instance_id
              ORDER BY SET_INDEX
            LOOP
                v_c_tablename := rec.c_tablename;
                IF rec.constrain_by_date_to IS NOT NULL THEN
                    v_constrain_by_date_to := to_char(rec.constrain_by_date_to, 'YYYY-MM-DD');
                ELSE
                    v_constrain_by_date_to := NULL;
                END IF;
                IF rec.constrain_by_date_from IS NOT NULL THEN
                    v_constrain_by_date_from := to_char(rec.constrain_by_date_from, 'YYYY-MM-DD');
                ELSE
                    v_constrain_by_date_from := NULL;
                END IF;
                v_constrain_by_value_operator   := rec.constrain_by_value_operator;
                v_constrain_by_value_constraint := rec.constrain_by_value_constraint;
                v_constrain_by_value_unit_of_measure := rec.constrain_by_value_unit_of_measure;
                v_constrain_by_value_type       := rec.constrain_by_value_type;
                v_c_facttablecolumn             := rec.c_facttablecolumn;
                v_c_columnname                  := rec.c_columnname;
                v_c_columndatatype              := rec.c_columndatatype;
                v_c_dimcode                     := rec.c_dimcode;
                v_c_operator                    := rec.c_operator;
                IF position('.' in v_c_facttablecolumn) > 0 THEN
                    v_c_facttable := substring(v_c_facttablecolumn from 1 for position('.' in v_c_facttablecolumn)-1);
                    v_c_facttablecolumn := replace(v_c_facttablecolumn, v_c_facttable || '.', '');
                END IF;
                v_constraint_sql := udf_constraint_sql(v_c_tablename,
                                                       v_constrain_by_date_from,
                                                       v_constrain_by_date_to,
                                                       v_constrain_by_value_operator,
                                                       v_constrain_by_value_constraint,
                                                       v_constrain_by_value_unit_of_measure,
                                                       v_constrain_by_value_type);
                v_ontology_constraint_sql := udf_constraint_ontology_sql(v_c_operator,
                                                                         v_c_columnname,
                                                                         v_c_columndatatype,
                                                                         v_c_dimcode);
                v_current_patientset_sql :=
                    'select distinct patient_num from ' || v_c_facttable || ' f ' ||
                    'where f.' || v_c_facttablecolumn || ' IN (' ||
                        'select ' || v_c_facttablecolumn || ' from ' || v_c_tablename ||
                        ' where ' || v_ontology_constraint_sql || ') ' || v_constraint_sql;
                IF v_union <> '' THEN
                    v_union := v_union || ' UNION ' || v_current_patientset_sql;
                ELSE
                    v_union := v_current_patientset_sql;
                END IF;
            END LOOP;
            v_patientset_sql :=
                'SELECT PATIENT_NUM FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (ORDER BY PATIENT_NUM) AS SET_INDEX FROM (' ||
                v_union ||
                ') x) x2 WHERE 1=1';
        END;
    END IF;
    IF p_min_row IS NOT NULL THEN
        v_patientset_sql := v_patientset_sql || ' AND SET_INDEX BETWEEN ' || p_min_row::TEXT || ' AND ' || p_max_row::TEXT;
    END IF;
    RETURN v_patientset_sql;
END;
$$ LANGUAGE plpgsql;
