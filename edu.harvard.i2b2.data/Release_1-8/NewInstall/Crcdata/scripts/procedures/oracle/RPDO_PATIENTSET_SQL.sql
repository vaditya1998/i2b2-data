create or replace FUNCTION udf_patientset_sql(
    p_RESULT_INSTANCE_ID IN NUMBER DEFAULT NULL,
    p_MIN_ROW            IN NUMBER DEFAULT NULL,
    p_MAX_ROW            IN NUMBER DEFAULT NULL,
    p_TABLE_INSTANCE_ID  IN NUMBER DEFAULT NULL
) RETURN CLOB
IS
    v_patientset_sql     CLOB := '';
    v_current_sql        CLOB := '';
    v_constraint_sql     CLOB := '';
    v_ontology_sql       CLOB := '';
    v_COHORT_COL_INDEX   NUMBER := 1;
    v_MAX_COHORT_COL_INDEX NUMBER := 0;
    CURSOR cohort_cursor IS
        SELECT ROWID, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE,
               C_OPERATOR, C_DIMCODE, CONSTRAIN_BY_DATE_TO, CONSTRAIN_BY_DATE_FROM,
               CONSTRAIN_BY_VALUE_OPERATOR, CONSTRAIN_BY_VALUE_CONSTRAINT,
               CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE, CONSTRAIN_BY_VALUE_TYPE
        FROM RPDO_TABLE_REQUEST
        WHERE USE_AS_COHORT = 'Y'
          AND TABLE_INSTANCE_ID = p_TABLE_INSTANCE_ID
          AND DELETE_FLAG = 'N'
        ORDER BY SET_INDEX;
BEGIN
    DBMS_OUTPUT.PUT_LINE('>>> udf_patientset_sql called.');

    IF p_RESULT_INSTANCE_ID IS NULL THEN
        v_patientset_sql := 'SELECT PATIENT_NUM FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (ORDER BY PATIENT_NUM) SET_INDEX FROM PATIENT_DIMENSION) WHERE 1=1';
    ELSIF p_RESULT_INSTANCE_ID > 0 THEN
        v_patientset_sql := 'SELECT PATIENT_NUM FROM QT_PATIENT_SET_COLLECTION WHERE RESULT_INSTANCE_ID = ' || p_RESULT_INSTANCE_ID;
    ELSIF p_RESULT_INSTANCE_ID = -1 THEN
        DBMS_OUTPUT.PUT_LINE('>>> Building patient set from COHORT constraints.');

        FOR cohort_rec IN cohort_cursor LOOP
            BEGIN
                v_constraint_sql := '';
                v_ontology_sql := '';

                -- Build constraint SQL safely
                BEGIN
                    v_constraint_sql := udf_constraint_sql(
                        cohort_rec.C_TABLENAME,
                        TO_CHAR(cohort_rec.CONSTRAIN_BY_DATE_FROM, 'YYYY-MM-DD'),
                        TO_CHAR(cohort_rec.CONSTRAIN_BY_DATE_TO, 'YYYY-MM-DD'),
                        cohort_rec.CONSTRAIN_BY_VALUE_OPERATOR,
                        cohort_rec.CONSTRAIN_BY_VALUE_CONSTRAINT,
                        cohort_rec.CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
                        cohort_rec.CONSTRAIN_BY_VALUE_TYPE
                    );
                EXCEPTION WHEN OTHERS THEN
                    v_constraint_sql := '';
                    DBMS_OUTPUT.PUT_LINE('>>> Error building constraint SQL: ' || SQLERRM);
                END;

                -- Build ontology constraint safely
                BEGIN
                    IF cohort_rec.C_DIMCODE IS NOT NULL AND cohort_rec.C_COLUMNNAME IS NOT NULL THEN
                        v_ontology_sql := udf_constraint_ontology_sql(
                            NVL(cohort_rec.C_OPERATOR, '='),
                            cohort_rec.C_COLUMNNAME,
                            cohort_rec.C_COLUMNDATATYPE,
                            cohort_rec.C_DIMCODE
                        );
                    ELSE
                        v_ontology_sql := '1=1';
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    v_ontology_sql := '1=1';
                    DBMS_OUTPUT.PUT_LINE('>>> Error building ontology constraint: ' || SQLERRM);
                END;

                -- Build the patient subset SQL
                v_current_sql := 'SELECT DISTINCT patient_num ' ||
                                 'FROM ' || NVL(cohort_rec.C_FACTTABLECOLUMN, 'observation_fact') || ' f ' ||
                                 'WHERE ' || v_ontology_sql || v_constraint_sql;

                -- Union results
                IF v_COHORT_COL_INDEX = 1 THEN
                    v_patientset_sql := v_current_sql;
                ELSE
                    v_patientset_sql := v_patientset_sql || ' UNION ' || v_current_sql;
                END IF;

                v_COHORT_COL_INDEX := v_COHORT_COL_INDEX + 1;

            EXCEPTION WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('>>> Error inside cohort loop: ' || SQLERRM);
            END;
        END LOOP;

        -- Wrap with row_number if needed
        v_patientset_sql := 'SELECT PATIENT_NUM FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (ORDER BY PATIENT_NUM) SET_INDEX FROM (' ||
                            v_patientset_sql || ')) WHERE 1=1';
    END IF;

    -- Apply row limits if needed
    IF p_MIN_ROW IS NOT NULL AND p_MAX_ROW IS NOT NULL THEN
        v_patientset_sql := v_patientset_sql || ' AND SET_INDEX BETWEEN ' || p_MIN_ROW || ' AND ' || p_MAX_ROW;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Generated Patientset SQL: ' || SUBSTR(v_patientset_sql, 1, 1000));

    RETURN v_patientset_sql;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in udf_patientset_sql: ' || SQLERRM);
        RETURN NULL;
END;
/

