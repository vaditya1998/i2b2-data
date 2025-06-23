IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'udf_rpdo_column_sql_dev')
                    AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT') ) 
DROP FUNCTION udf_rpdo_column_sql_dev
;
CREATE FUNCTION [dbo].[udf_rpdo_column_sql_dev]
(
	@PATIENTSET_SQL NVARCHAR(MAX),

	@COLUMN_NAME VARCHAR(1000),

	@C_FACTTABLECOLUMN VARCHAR(50),
	@C_TABLENAME VARCHAR(50),
	@C_COLUMNNAME VARCHAR(30),
	@C_COLUMNDATATYPE VARCHAR(50),
	@C_DIMCODE VARCHAR(1000),
	@C_OPERATOR VARCHAR(30),

	@CONSTRAIN_BY_DATE_TO Varchar(100) = NULL,
	@CONSTRAIN_BY_DATE_FROM Varchar(100) = NULL,
	@CONSTRAIN_BY_VALUE_OPERATOR VARCHAR(20) = NULL,
	@CONSTRAIN_BY_VALUE_CONSTRAINT VARCHAR(1000) = NULL ,
	@CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE VARCHAR(50) = NULL,
	@CONSTRAIN_BY_VALUE_TYPE VARCHAR(50) = NULL,

	@AGG_TYPE VARCHAR(50),

	@TABLE_INSTANCE_ID INT,

	@CONSTRAIN_BY_INDEXDATE_COLUMNNAME VARCHAR(1000) = NULL,
	@CONSTRAIN_BY_INDEXDATE_FROM_DAYS INT = NULL,
	@CONSTRAIN_BY_INDEXDATE_TO_DAYS INT = NULL
)
RETURNS NVARCHAR(MAX)
BEGIN


	---TODO: Change all function calls to EXEC for named parameters
/*
	--QA
	DECLARE @RESULT_INSTANCE_ID INT = NULL -- from QT_PATIENT_SET_COLLECTION table
	DECLARE @MIN_ROW INT = NULL --Batch starting row
	DECLARE @MAX_ROW INT = NULL --Batch ending row
	DECLARE @SET_INDEX INT = NULL

	DECLARE @COLUMN_NAME VARCHAR(1000) = 'blah'

	DECLARE @C_FACTTABLECOLUMN VARCHAR(50) = 'observation_fact.concept_cd'
	DECLARE @C_TABLENAME VARCHAR(50)= 'concept_dimension'
	DECLARE @C_COLUMNNAME VARCHAR(50)= 'concept_path'
	DECLARE @C_COLUMNDATATYPE VARCHAR(50)= 'T'
	DECLARE @C_DIMCODE VARCHAR(1000)= '\i2b2metadata\Medications_RxNorm\MRX\(N0000029116)~ynr0\(N0000029122)~09dh\'
	DECLARE @C_OPERATOR VARCHAR(50)= 'LIKE'

	DECLARE	@CONSTRAIN_BY_DATE_TO Varchar(10) = '12/1/2019 12:00'
	DECLARE @CONSTRAIN_BY_DATE_FROM Varchar(10) = '12/31/2019 12:00'
	DECLARE @CONSTRAIN_BY_VALUE_OPERATOR VARCHAR(20) = 'GE'
	DECLARE @CONSTRAIN_BY_VALUE_CONSTRAINT VARCHAR(1000) = '6.5'
	DECLARE @CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE VARCHAR(50) = ''
	DECLARE @CONSTRAIN_BY_VALUE_TYPE VARCHAR(50) = 'N'

	DECLARE @AGG_TYPE VARCHAR(50) = 'Exists'
	*/


	DECLARE @rpdo_column_sql NVARCHAR(MAX)

	DECLARE @constraint_sql NVARCHAR(MAX)
	DECLARE @indexdate_constraint_sql NVARCHAR(MAX) = ''
	DECLARE @ontology_constraint_sql NVARCHAR(MAX)
	DECLARE @aggregation_sql NVARCHAR(MAX)


	IF @C_TABLENAME = 'patient_dimension' AND @AGG_TYPE = 'Value'
	BEGIN
		-- Numeric ---------------------------------------------------
		IF @C_COLUMNDATATYPE = 'N'
		BEGIN
			SET @rpdo_column_sql =
				'SELECT patient_num, ''' + @COLUMN_NAME + ''' AS col, ' +
				 @C_FACTTABLECOLUMN + ' AS val ' +
				'FROM patient_dimension ' +
				'WHERE patient_num IN (' + @PATIENTSET_SQL + ')';
			RETURN @rpdo_column_sql;
		END

		-- Text/String -----------------------------------------------
		ELSE IF @C_COLUMNDATATYPE IN ('T','S')
		BEGIN
			SET @rpdo_column_sql =
				'SELECT patient_num, ''' + @COLUMN_NAME + ''' AS col, ' +
				'CONVERT(VARCHAR(100), ' + @C_FACTTABLECOLUMN + ') AS val ' +
				'FROM patient_dimension ' +
				'WHERE patient_num IN (' + @PATIENTSET_SQL + ')';
			RETURN @rpdo_column_sql;
		END

		-- Date ------------------------------------------------------
		ELSE IF @C_COLUMNDATATYPE = 'D'
		BEGIN
			SET @rpdo_column_sql =
				'SELECT patient_num, ''' + @COLUMN_NAME + ''' AS col, ' +
				'CONVERT(VARCHAR(10), ' + @C_FACTTABLECOLUMN + ', 23) AS val ' +
				'FROM patient_dimension ' +
				'WHERE patient_num IN (' + @PATIENTSET_SQL + ')';
			RETURN @rpdo_column_sql;
		END

		-- Fallback (anything else as text) -------------------------
		ELSE
		BEGIN
			SET @rpdo_column_sql =
				'SELECT patient_num, ''' + @COLUMN_NAME + ''' AS col, ' +
				 @C_FACTTABLECOLUMN + ' AS val ' +
				'FROM patient_dimension ' +
				'WHERE patient_num IN (' + @PATIENTSET_SQL + ')';
			RETURN @rpdo_column_sql;
		END
	END

	/*IF @C_TABLENAME = 'patient_dimension' and @AGG_TYPE = 'Value'
	BEGIN
		SELECT @rpdo_column_sql = 'select patient_num, ''' + @COLUMN_NAME + ''' col,
				CONVERT(VARCHAR(100), ' + @C_FACTTABLECOLUMN + ', 23)
				val from patient_dimension
				where patient_num IN (' + @PATIENTSET_SQL + ')'
	END*/
	
	ELSE IF @C_TABLENAME = 'qt_patient_set_collection' and @AGG_TYPE = 'Exists'
	BEGIN
		SELECT @rpdo_column_sql = 'select patient_num, ''' + @COLUMN_NAME + ''' col,
				''Yes''	val from QT_PATIENT_SET_COLLECTION
				where RESULT_INSTANCE_ID = ' + @C_DIMCODE + ' AND patient_num IN (' + @PATIENTSET_SQL + ')'
	END
	ELSE
	BEGIN

		EXEC @constraint_sql = dbo.udf_constraint_sql
				@C_TABLENAME = @C_TABLENAME,
				@CONSTRAIN_BY_DATE_TO = @CONSTRAIN_BY_DATE_TO ,
				@CONSTRAIN_BY_DATE_FROM = @CONSTRAIN_BY_DATE_FROM ,
				@CONSTRAIN_BY_VALUE_OPERATOR = @CONSTRAIN_BY_VALUE_OPERATOR,
				@CONSTRAIN_BY_VALUE_CONSTRAINT= @CONSTRAIN_BY_VALUE_CONSTRAINT ,
				@CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE = @CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
				@CONSTRAIN_BY_VALUE_TYPE = @CONSTRAIN_BY_VALUE_TYPE

		SELECT @ontology_constraint_sql = dbo.udf_constraint_ontology_sql(
			@C_OPERATOR,
			@C_COLUMNNAME,
			@C_COLUMNDATATYPE,
			@C_DIMCODE
		)

		SELECT @aggregation_sql = dbo.udf_aggregation_sql(
			@AGG_TYPE
		)


		IF @CONSTRAIN_BY_INDEXDATE_COLUMNNAME IS NOT NULL
		BEGIN
			SELECT @indexdate_constraint_sql = dbo.udf_indexdate_constraint_sql(
				@TABLE_INSTANCE_ID,
				@CONSTRAIN_BY_INDEXDATE_COLUMNNAME,
				@CONSTRAIN_BY_INDEXDATE_FROM_DAYS,
				@CONSTRAIN_BY_INDEXDATE_TO_DAYS
			)
		END

		-- Support multifact tables
		DECLARE @C_FACTTABLE VARCHAR(100) = 'observation_fact'
		IF @C_FACTTABLECOLUMN LIKE '%.%'
		BEGIN
			SET @C_FACTTABLE = LEFT(@C_FACTTABLECOLUMN, charindex('.', @C_FACTTABLECOLUMN)-1)
			SET @C_FACTTABLECOLUMN = replace(@C_FACTTABLECOLUMN, @C_FACTTABLE+'.', '')
		END

		IF @C_TABLENAME = 'concept_dimension'
			select @rpdo_column_sql =
				'with t as (select distinct patient_num, encounter_num, concept_cd, start_date, provider_id, tval_char, nval_num '

		IF @C_TABLENAME = 'patient_dimension'
			select @rpdo_column_sql =
				'with t as (select patient_num '

		IF @C_TABLENAME = 'visit_dimension'
			select @rpdo_column_sql =
				'with t as (select distinct patient_num, encounter_num, start_date, ' + @C_FACTTABLECOLUMN + ' '


		select @rpdo_column_sql +=
			'from ' + @C_FACTTABLE + ' f
			 where patient_num IN (' + @PATIENTSET_SQL + ') and
			 f.' + @C_FACTTABLECOLUMN + ' IN
				(select ' + @C_FACTTABLECOLUMN + '
				 from ' + @C_TABLENAME + '
				 where ' + @ontology_constraint_sql + ') ' +
				 @constraint_sql + @indexdate_constraint_sql + ') '


		IF @AGG_TYPE LIKE 'Multi%'
		BEGIN
			select @rpdo_column_sql += 'select distinct patient_num, ' + @aggregation_sql
		END
		ELSE
		BEGIN
			select @rpdo_column_sql += 'select distinct patient_num, ''' + REPLACE(@COLUMN_NAME,'''','''''') + ''' col, ' +
				@aggregation_sql
		END


	 END
	--SELECT @rpdo_column_sql

	RETURN @rpdo_column_sql

END

