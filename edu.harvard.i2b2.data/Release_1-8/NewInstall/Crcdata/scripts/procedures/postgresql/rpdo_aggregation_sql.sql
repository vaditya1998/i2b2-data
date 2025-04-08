CREATE OR REPLACE FUNCTION udf_aggregation_sql(p_agg_type TEXT)
RETURNS TEXT AS $$
DECLARE
    v_aggregation_sql TEXT;
BEGIN
    IF p_agg_type = 'Exists' THEN
        v_aggregation_sql := '''Yes'' val from t';
    ELSIF p_agg_type = 'NumEncounters' THEN
        v_aggregation_sql := 'COUNT(DISTINCT ENCOUNTER_NUM) val from t group by patient_num';
    ELSIF p_agg_type = 'NumConcepts' THEN
        v_aggregation_sql := 'COUNT(DISTINCT CONCEPT_CD) val from t group by patient_num';
    ELSIF p_agg_type = 'NumProviders' THEN
        v_aggregation_sql := 'COUNT(DISTINCT PROVIDER_ID) val from t where PROVIDER_ID <> ''@'' group by patient_num';
    ELSIF p_agg_type = 'NumDates' THEN
        v_aggregation_sql := 'COUNT(DISTINCT DATE(START_DATE)) val from t group by patient_num';
    ELSIF p_agg_type = 'NumFacts' THEN
        v_aggregation_sql := 'COUNT(*) val from t group by patient_num';
    ELSIF p_agg_type = 'NumValues' THEN
        v_aggregation_sql := 'COUNT(DISTINCT NVAL_NUM) val from t group by patient_num';
    ELSIF p_agg_type = 'MinDate' THEN
        v_aggregation_sql := 'MIN(START_DATE) val from t group by patient_num';
    ELSIF p_agg_type = 'MaxDate' THEN
        v_aggregation_sql := 'MAX(START_DATE) val from t group by patient_num';
    ELSIF p_agg_type = 'MinValue' THEN
        v_aggregation_sql := 'MIN(NVAL_NUM) val from t group by patient_num';
    ELSIF p_agg_type = 'MaxValue' THEN
        v_aggregation_sql := 'MAX(NVAL_NUM) val from t group by patient_num';
    ELSIF p_agg_type = 'AvgValue' THEN
        v_aggregation_sql := 'AVG(NVAL_NUM) val from t group by patient_num';
    ELSIF p_agg_type = 'MedianValue' THEN
        v_aggregation_sql := 'PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY NVAL_NUM) OVER (PARTITION BY PATIENT_NUM) val from t';
    ELSIF p_agg_type = 'FirstValue' THEN
        v_aggregation_sql := 'NVAL_NUM val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE ASC) rn, NVAL_NUM from t) x where rn = 1';
    ELSIF p_agg_type = 'LastValue' THEN
        v_aggregation_sql := 'NVAL_NUM val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE DESC) rn, NVAL_NUM from t) x where rn = 1';
    ELSIF p_agg_type = 'FirstValueEnum' THEN
        v_aggregation_sql := 'TVAL_CHAR val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE ASC) rn, TVAL_CHAR from t) x where rn = 1';
    ELSIF p_agg_type = 'LastValueEnum' THEN
        v_aggregation_sql := 'TVAL_CHAR val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE DESC) rn, TVAL_CHAR from t) x where rn = 1';
    ELSIF p_agg_type = 'MedianDate' THEN
        v_aggregation_sql := ' (min(START_DATE) + ((max(START_DATE) - min(START_DATE)) / 2)) val FROM ( ' ||
                             'SELECT PATIENT_NUM, START_DATE, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE) SEQ_NUM, COUNT(*) OVER (PARTITION BY PATIENT_NUM) CNT FROM t) x ' ||
                             'where 2 * SEQ_NUM in (CNT, CNT + 1, CNT + 2) group by patient_num';
    ELSIF p_agg_type = 'ModeValue' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || LABEL || ''] '', '''' ORDER BY LABEL) ' ||
                             'FROM (SELECT PATIENT_NUM, CAST(NVAL_NUM AS TEXT) || '' ('' || CAST(COUNT(*) AS TEXT) || '')'' AS LABEL, ' ||
                             'DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) AS rnk ' ||
                             'FROM t GROUP BY patient_num, nval_num) x ' ||
                             'WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val from t';
    ELSIF p_agg_type = 'ModeEnumValue' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || LABEL || ''] '', '''' ORDER BY LABEL) ' ||
                             'FROM (SELECT PATIENT_NUM, TVAL_CHAR || '' ('' || CAST(COUNT(*) AS TEXT) || '')'' AS LABEL, ' ||
                             'DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) AS rnk ' ||
                             'FROM t GROUP BY patient_num, tval_char) x ' ||
                             'WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val from t';
    ELSIF p_agg_type = 'ModeConceptCode' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || LABEL || ''] '', '''' ORDER BY LABEL) ' ||
                             'FROM (SELECT PATIENT_NUM, CONCEPT_CD || '' ('' || CAST(COUNT(*) AS TEXT) || '')'' AS LABEL, ' ||
                             'DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) AS rnk ' ||
                             'FROM t GROUP BY patient_num, concept_cd) x ' ||
                             'WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val from t';
    ELSIF p_agg_type = 'ModeConceptName' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || LABEL || ''] '', '''' ORDER BY LABEL) ' ||
                             'FROM (SELECT t.PATIENT_NUM, c.NAME_CHAR || '' ('' || CAST(COUNT(*) AS TEXT) || '')'' AS LABEL, ' ||
                             'DENSE_RANK() OVER (PARTITION BY t.PATIENT_NUM ORDER BY COUNT(*) DESC) AS rnk ' ||
                             'FROM t INNER JOIN concept_dimension c ON c.concept_cd = t.concept_cd GROUP BY t.PATIENT_NUM, c.NAME_CHAR) x ' ||
                             'WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val from t';
    ELSIF p_agg_type = 'ModeDate' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || LABEL || ''] '', '''' ORDER BY LABEL) ' ||
                             'FROM (SELECT PATIENT_NUM, TO_CHAR(START_DATE, ''YYYY-MM-DD'') || '' ('' || CAST(COUNT(*) AS TEXT) || '')'' AS LABEL, ' ||
                             'DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY COUNT(*) DESC) AS rnk ' ||
                             'FROM t GROUP BY patient_num, START_DATE) x ' ||
                             'WHERE rnk = 1 AND x.PATIENT_NUM = t.PATIENT_NUM) val from t';
    ELSIF p_agg_type = 'ConceptCodes' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || concept_cd || ''] '', '''' ORDER BY concept_cd) ' ||
                             'FROM (SELECT DISTINCT concept_cd FROM t x WHERE x.patient_num = t.patient_num)) val from t';
    ELSIF p_agg_type = 'ConceptNames' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || c.NAME_CHAR || ''] '', '''' ORDER BY c.NAME_CHAR) ' ||
                             'FROM (SELECT DISTINCT c.NAME_CHAR FROM t x INNER JOIN concept_dimension c ON c.concept_cd = x.concept_cd WHERE x.patient_num = t.patient_num)) val from t';
    ELSIF p_agg_type = 'AllValues' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || CAST(nval_num AS TEXT) || ''] '', '''' ORDER BY nval_num) ' ||
                             'FROM (SELECT DISTINCT nval_num FROM t x WHERE x.patient_num = t.patient_num)) val from t';
    ELSIF p_agg_type = 'AllDates' THEN
        v_aggregation_sql := ' (SELECT STRING_AGG(''['' || TO_CHAR(start_date, ''YYYY-MM-DD'') || ''] '', '''' ORDER BY start_date) ' ||
                             'FROM (SELECT DISTINCT start_date FROM t x WHERE x.patient_num = t.patient_num)) val from t';
    ELSIF p_agg_type = 'MultiACTDrugIng' THEN
        v_aggregation_sql := 'REPLACE(CONCEPT_NAME, '','', '''') col, COUNT(DISTINCT START_DATE) val ' ||
                             'from t inner join ACT_DRUG_ING i on t.CONCEPT_CD = i.CONCEPT_CD group by patient_num, concept_name';
    ELSE
        v_aggregation_sql := NULL;
    END IF;
    RETURN v_aggregation_sql;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '';
END;
$$ LANGUAGE plpgsql;
