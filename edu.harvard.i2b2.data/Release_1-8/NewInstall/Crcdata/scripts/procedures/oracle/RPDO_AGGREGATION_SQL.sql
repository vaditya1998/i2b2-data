create or replace FUNCTION udf_aggregation_sql (
    p_AGG_TYPE IN VARCHAR2
) RETURN CLOB
IS
    v_aggregation_sql CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE('>>> udf_aggregation_sql called with AGG_TYPE = ' || p_AGG_TYPE);

    CASE p_AGG_TYPE
        WHEN 'Exists' THEN
            v_aggregation_sql := '''Yes'' val from t';

        WHEN 'NumEncounters' THEN
            v_aggregation_sql := 'COUNT(DISTINCT ENCOUNTER_NUM) val from t group by patient_num';

        WHEN 'NumConcepts' THEN
            v_aggregation_sql := 'COUNT(DISTINCT CONCEPT_CD) val from t group by patient_num';

        WHEN 'NumProviders' THEN
            v_aggregation_sql := 'COUNT(DISTINCT PROVIDER_ID) val from t where PROVIDER_ID <> ''@'' group by patient_num';

        WHEN 'NumDates' THEN
            v_aggregation_sql := 'COUNT(DISTINCT TRUNC(START_DATE)) val from t group by patient_num';

        WHEN 'NumFacts' THEN
            v_aggregation_sql := 'COUNT(*) val from t group by patient_num';

        WHEN 'NumValues' THEN
            v_aggregation_sql := 'COUNT(DISTINCT NVAL_NUM) val from t group by patient_num';

        WHEN 'MinDate' THEN
            v_aggregation_sql := 'MIN(TRUNC(START_DATE)) val from t group by patient_num';

        WHEN 'MaxDate' THEN
            v_aggregation_sql := 'MAX(TRUNC(START_DATE)) val from t group by patient_num';

        WHEN 'MinValue' THEN
            v_aggregation_sql := 'MIN(NVAL_NUM) val from t group by patient_num';

        WHEN 'MaxValue' THEN
            v_aggregation_sql := 'MAX(NVAL_NUM) val from t group by patient_num';

        WHEN 'AvgValue' THEN
            v_aggregation_sql := 'AVG(NVAL_NUM) val from t group by patient_num';

        WHEN 'MedianValue' THEN
            v_aggregation_sql := 'PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY NVAL_NUM) OVER (PARTITION BY PATIENT_NUM) val from t';

        WHEN 'FirstValue' THEN
            v_aggregation_sql := 'NVAL_NUM val FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE ASC) rn, NVAL_NUM FROM t) x WHERE rn = 1';

        WHEN 'LastValue' THEN
            v_aggregation_sql := 'NVAL_NUM val FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE DESC) rn, NVAL_NUM FROM t) x WHERE rn = 1';

        WHEN 'FirstValueEnum' THEN
            v_aggregation_sql := 'TVAL_CHAR val FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE ASC) rn, TVAL_CHAR FROM t) x WHERE rn = 1';

        WHEN 'LastValueEnum' THEN
            v_aggregation_sql := 'TVAL_CHAR val FROM (SELECT PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE DESC) rn, TVAL_CHAR FROM t) x WHERE rn = 1';

        WHEN 'MedianDate' THEN
            v_aggregation_sql := '(MIN(START_DATE) + ((MAX(START_DATE) - MIN(START_DATE)) / 2)) val FROM (
                                    SELECT PATIENT_NUM, START_DATE, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE) SEQ_NUM,
                                           COUNT(*) OVER (PARTITION BY PATIENT_NUM) CNT FROM t
                                  ) x
                                  WHERE 2 * SEQ_NUM IN (CNT, CNT + 1, CNT + 2)
                                  GROUP BY PATIENT_NUM';

        WHEN 'ConceptCodes' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || concept_cd || ''] '', '''') WITHIN GROUP (ORDER BY concept_cd)
                                   FROM (SELECT DISTINCT concept_cd FROM t x WHERE x.patient_num = t.patient_num)) val FROM t';

        WHEN 'ConceptNames' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || c.NAME_CHAR || ''] '', '''') WITHIN GROUP (ORDER BY c.NAME_CHAR)
                                   FROM (SELECT DISTINCT c.NAME_CHAR FROM t x INNER JOIN concept_dimension c
                                         ON c.CONCEPT_CD = x.CONCEPT_CD WHERE x.patient_num = t.patient_num)) val FROM t';

        WHEN 'AllValues' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || TO_CHAR(nval_num) || ''] '', '''') WITHIN GROUP (ORDER BY nval_num)
                                   FROM (SELECT DISTINCT nval_num FROM t x WHERE x.patient_num = t.patient_num)) val FROM t';

        WHEN 'AllDates' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || TO_CHAR(start_date, ''YYYY-MM-DD'') || ''] '', '''') WITHIN GROUP (ORDER BY start_date)
                                   FROM (SELECT DISTINCT start_date FROM t x WHERE x.patient_num = t.patient_num)) val FROM t';

        WHEN 'ModeValue' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || LABEL || ''] '', '''') WITHIN GROUP (ORDER BY LABEL)
                                   FROM (SELECT PATIENT_NUM, TO_CHAR(NVAL_NUM) || '' ('' || COUNT(*) || '')'' AS LABEL,
                                                DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) rnk
                                         FROM t GROUP BY patient_num, nval_num) x
                                   WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val FROM t';

        WHEN 'ModeEnumValue' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || LABEL || ''] '', '''') WITHIN GROUP (ORDER BY LABEL)
                                   FROM (SELECT PATIENT_NUM, TVAL_CHAR || '' ('' || COUNT(*) || '')'' AS LABEL,
                                                DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) rnk
                                         FROM t GROUP BY patient_num, TVAL_CHAR) x
                                   WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val FROM t';

        WHEN 'ModeConceptCode' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || LABEL || ''] '', '''') WITHIN GROUP (ORDER BY LABEL)
                                   FROM (SELECT PATIENT_NUM, CONCEPT_CD || '' ('' || COUNT(*) || '')'' AS LABEL,
                                                DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) rnk
                                         FROM t GROUP BY patient_num, concept_cd) x
                                   WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val FROM t';

        WHEN 'ModeConceptName' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || LABEL || ''] '', '''') WITHIN GROUP (ORDER BY LABEL)
                                   FROM (SELECT t.PATIENT_NUM, c.NAME_CHAR || '' ('' || COUNT(*) || '')'' AS LABEL,
                                                DENSE_RANK() OVER (PARTITION BY t.PATIENT_NUM ORDER BY COUNT(*) DESC) rnk
                                         FROM t INNER JOIN concept_dimension c ON c.concept_cd = t.concept_cd
                                         GROUP BY t.PATIENT_NUM, c.NAME_CHAR) x
                                   WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val FROM t';

        WHEN 'ModeDate' THEN
            v_aggregation_sql := '(SELECT LISTAGG(''['' || LABEL || ''] '', '''') WITHIN GROUP (ORDER BY LABEL)
                                   FROM (SELECT PATIENT_NUM, TO_CHAR(START_DATE, ''YYYY-MM-DD'') || '' ('' || COUNT(*) || '')'' AS LABEL,
                                                DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) rnk
                                         FROM t GROUP BY patient_num, START_DATE) x
                                   WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val FROM t';

        WHEN 'MultiACTDrugIng' THEN
            v_aggregation_sql := 'REPLACE(CONCEPT_NAME, '','', '''') col, COUNT(DISTINCT START_DATE) val
                                  FROM t INNER JOIN ACT_DRUG_ING i ON t.CONCEPT_CD = i.CONCEPT_CD
                                  GROUP BY patient_num, concept_name';

        ELSE
            v_aggregation_sql := '''<no-agg>'' val from t';
    END CASE;

    DBMS_OUTPUT.PUT_LINE('Generated Aggregation SQL:');
    DBMS_OUTPUT.PUT_LINE(SUBSTR(v_aggregation_sql, 1, 1000));
    RETURN v_aggregation_sql;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in udf_aggregation_sql: ' || SQLERRM);
        RETURN NULL;
END udf_aggregation_sql;


