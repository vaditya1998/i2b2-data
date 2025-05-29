CREATE FUNCTION [dbo].[udf_aggregation_sql]
(
	@AGG_TYPE VARCHAR(1000)
)
RETURNS NVARCHAR(MAX)
BEGIN

	--DECLARE @AGG_TYPE NVARCHAR(1000) = 'Exists'

	DECLARE @aggregation_sql NVARCHAR(MAX)

	IF @AGG_TYPE = 'Exists'
		SELECT @aggregation_sql = '''Yes'' val from t RECOMPILE'

	IF @AGG_TYPE = 'NumEncounters'
		SELECT @aggregation_sql = 'COUNT(DISTINCT ENCOUNTER_NUM) val from t group by patient_num'

	IF @AGG_TYPE = 'NumConcepts'
		SELECT @aggregation_sql = 'COUNT(DISTINCT CONCEPT_CD) val from t group by patient_num'

	IF @AGG_TYPE = 'NumProviders'
		SELECT @aggregation_sql = 'COUNT(DISTINCT PROVIDER_ID) val from t where PROVIDER_ID <> ''@'' group by patient_num'

	IF @AGG_TYPE = 'NumDates'
		SELECT @aggregation_sql = 'COUNT(DISTINCT CONVERT(date, START_DATE)) val from t group by patient_num'

	IF @AGG_TYPE = 'NumFacts'
		SELECT @aggregation_sql = 'COUNT(*) val from t group by patient_num'

	IF @AGG_TYPE = 'NumValues'
		SELECT @aggregation_sql = 'COUNT(DISTINCT NVAL_NUM) val from t group by patient_num'

	IF @AGG_TYPE = 'MinDate'
		SELECT @aggregation_sql = 'MIN(CONVERT(date, START_DATE)) val from t group by patient_num'

	IF @AGG_TYPE = 'MaxDate'
		SELECT @aggregation_sql = 'MAX(CONVERT(date, START_DATE)) val from t group by patient_num'

	IF @AGG_TYPE = 'MinValue'
		SELECT @aggregation_sql = 'MIN(NVAL_NUM) val from t group by patient_num'

	IF @AGG_TYPE = 'MaxValue'
		SELECT @aggregation_sql = 'MAX(NVAL_NUM) val from t group by patient_num'

	IF @AGG_TYPE = 'AvgValue'
		SELECT @aggregation_sql = 'AVG(NVAL_NUM) val from t group by patient_num'

	IF @AGG_TYPE = 'MedianValue'
		SELECT @aggregation_sql = 'PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY NVAL_NUM) OVER (PARTITION BY PATIENT_NUM) val from t'

	IF @AGG_TYPE = 'FirstValue'
		SELECT @aggregation_sql = 'NVAL_NUM val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE ASC) rn, NVAL_NUM from t) x where rn = 1'

	IF @AGG_TYPE = 'LastValue'
		SELECT @aggregation_sql = 'NVAL_NUM val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE DESC) rn, NVAL_NUM from t) x where rn = 1'

	IF @AGG_TYPE = 'FirstValueEnum'
		SELECT @aggregation_sql = 'TVAL_CHAR val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE ASC) rn, TVAL_CHAR from t) x where rn = 1 OPTION(RECOMPILE)'

	IF @AGG_TYPE = 'LastValueEnum'
		SELECT @aggregation_sql = 'TVAL_CHAR val FROM (select PATIENT_NUM, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE DESC) rn, TVAL_CHAR from t) x where rn = 1 OPTION(RECOMPILE)'

	IF @AGG_TYPE = 'MedianDate'
		SELECT @aggregation_sql = 'DATEADD(day, datediff(hour, min(START_DATE), max(START_DATE)) / 2.0, min(START_DATE)) val FROM (
									SELECT PATIENT_NUM, START_DATE, ROW_NUMBER() OVER (PARTITION BY PATIENT_NUM ORDER BY START_DATE) SEQ_NUM, COUNT(*) OVER (PARTITION BY PATIENT_NUM) CNT FROM t) x
									where 2 * SEQ_NUM in (CNT, CNT + 1, CNT + 2) group by PATIENT_NUM'

	IF @AGG_TYPE = 'ModeValue'
	   SELECT @aggregation_sql = 'STUFF((SELECT ''['' + LABEL + ''] '' FROM
					(select PATIENT_NUM, CONVERT(VARCHAR(30), NVAL_NUM) + '' ('' + CONVERT(VARCHAR(5), COUNT(*)) + '')'' LABEL, DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY Count(*) DESC) rnk from t group by patient_num, nval_num) x
					where rnk = 1 and x.PATIENT_NUM = t.PATIENT_NUM
					FOR XML PATH('''')), 1,0, '''') val
			from t'

	IF @AGG_TYPE = 'ModeEnumValue'
	   SELECT @aggregation_sql = 'STUFF((SELECT ''['' + LABEL + ''] '' FROM
					(select PATIENT_NUM, CONVERT(VARCHAR(30), TVAL_CHAR) + '' ('' + CONVERT(VARCHAR(5), COUNT(*)) + '')'' LABEL, DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY Count(*) DESC) rnk from t group by patient_num, tval_char) x
					where rnk = 1 and x.PATIENT_NUM = t.PATIENT_NUM
					FOR XML PATH('''')), 1,0, '''') val
			from t'

	IF @AGG_TYPE = 'ModeConceptCode'
	   SELECT @aggregation_sql = 'STUFF((SELECT ''['' + LABEL + ''] '' FROM
					(select PATIENT_NUM, CONCEPT_CD + '' ('' + CONVERT(VARCHAR(5), COUNT(*)) + '')'' LABEL, DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY Count(*) DESC) rnk from t group by patient_num, concept_cd) x
					where rnk = 1 and x.PATIENT_NUM = t.PATIENT_NUM
					FOR XML PATH('''')), 1,0, '''') val
			from t'

	IF @AGG_TYPE = 'ModeConceptName'
	   SELECT @aggregation_sql = 'STUFF((SELECT ''['' + LABEL + ''] '' FROM
					(select PATIENT_NUM, NAME_CHAR + '' ('' + CONVERT(VARCHAR(5), COUNT(*)) + '')'' LABEL, DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY Count(*) DESC) rnk from t inner join concept_dimension c on c.concept_cd = t.concept_cd group by patient_num, NAME_CHAR) x
					where rnk = 1 and x.PATIENT_NUM = t.PATIENT_NUM
					FOR XML PATH('''')), 1,0, '''') val
			from t'

	IF @AGG_TYPE = 'ModeDate'
	   SELECT @aggregation_sql = 'STUFF((SELECT ''['' + LABEL + ''] '' FROM
					(SELECT PATIENT_NUM, CONVERT(VARCHAR(30), START_DATE) + '' ('' + CONVERT(VARCHAR(5), COUNT(*)) + '')'' LABEL, DENSE_RANK() OVER (PARTITION BY PATIENT_NUM ORDER BY Count(*) DESC) rnk from t group by patient_num, START_DATE) x
					where rnk = 1 and x.PATIENT_NUM = t.PATIENT_NUM
					FOR XML PATH('''')), 1,0, '''') val
			from t'

	IF @AGG_TYPE = 'ConceptCodes'
		   SELECT @aggregation_sql = 'STUFF(
				(SELECT DISTINCT ''[''+concept_cd+''] '' from t x where x.patient_num = t.patient_num FOR XML PATH('''')),
			1,0, '''') val
		from t'

	IF @AGG_TYPE = 'ConceptNames'
		   SELECT @aggregation_sql = 'STUFF(
				(SELECT DISTINCT ''[''+c.NAME_CHAR+''] '' from t x inner join concept_dimension c on c.CONCEPT_CD = x.CONCEPT_CD where x.patient_num = t.patient_num FOR XML PATH('''')),
			1,0, '''')
		from t'


	IF @AGG_TYPE = 'AllValues'
		   SELECT @aggregation_sql = 'STUFF(
				(SELECT DISTINCT ''[''+cast(nval_num as VARCHAR(100))+''] '' from t x where x.patient_num = t.patient_num FOR XML PATH('''')),
			1,0, '''') val
		from t'

	IF @AGG_TYPE = 'AllDates'
		   SELECT @aggregation_sql = 'STUFF(
				(SELECT DISTINCT ''[''+convert(varchar(20), start_date, 23)+''] '' from t x where x.patient_num = t.patient_num FOR XML PATH('''')),
			1,0, '''') val
		from t'

	IF @AGG_TYPE = 'MultiACTDrugIng'
			SELECT @aggregation_sql = 'replace(CONCEPT_NAME, '','', '''') col, COUNT(DISTINCT START_DATE) val
				from t
				inner join ACT_DRUG_ING i on t.CONCEPT_CD = i.CONCEPT_CD
				group by patient_num, concept_name'


	RETURN @aggregation_sql

END
go

