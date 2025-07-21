/*
################################################################################
-- File:    usp_rpdo2.sql (Postgres version)
-- Purpose: PL/pgSQL procedure to generate pivoted custom tables for I2B2 query
--          results, returning via REF_CURSOR.
--
-- Invocation:
--   -- 1. Load the script into your session:
--       \i /path/to/usp_rpdo2_postgres.sql
--
--   -- 2. Call the proc (uses default cursor name 'cur' and example parameters):
--       BEGIN;
--         CALL usp_rpdo2(
--           p_table_instance_id  => 322,
--           p_result_instance_id => 1333,
--           p_min_row            => 1,
--           p_max_row            => 10
--         );
--         FETCH ALL FROM cur;
--       COMMIT;
--
--   -- 3. (Optional) specify a custom cursor name:
--       BEGIN;
--         CALL usp_rpdo2(322, NULL, NULL, NULL, 'my_cursor');
--         FETCH ALL FROM my_cursor;
--       COMMIT;
--
-- Notes:
--   - Defaults the INOUT cur REFCURSOR parameter to 'cur'.
--   - Requires PostgreSQL 11+ (REFCURSOR support).
--
-- © 2025 Massachusetts General Hospital
################################################################################
*/


CREATE OR REPLACE PROCEDURE usp_rpdo2(
    p_table_instance_id  INTEGER,
    p_result_instance_id INTEGER DEFAULT NULL,
    p_min_row            INTEGER DEFAULT NULL,
    p_max_row            INTEGER DEFAULT NULL,
    INOUT cur 			 REFCURSOR DEFAULT 'cur'
) AS $body$
DECLARE
    v_patientset_sql TEXT;
    v_set_index INTEGER := 0;
    v_max_set_index INTEGER;
    v_column_sql TEXT;
    v_tmp_row RECORD;
    rec RECORD;  -- Record variable for dynamic SQL loop
    v_select_col TEXT := '';
    v_pivot_sql TEXT;
BEGIN
    -- Clear temporary tables
BEGIN
	CREATE TEMPORARY TABLE TMP_COLUMN_DEFINITIONS (
		TABLE_INSTANCE_NAME                VARCHAR(250),
		USER_ID                            VARCHAR(50),
		GROUP_ID                           VARCHAR(50),
		SET_INDEX                          INTEGER,
		C_FACTTABLECOLUMN                  VARCHAR(50),
		C_TABLENAME                        VARCHAR(100),
		C_FULLPATH                         VARCHAR(700),
		C_COLUMNNAME                       VARCHAR(30),
		COLUMN_NAME						   VARCHAR(1000),
		C_OPERATOR                         VARCHAR(30),
		C_DIMCODE                          VARCHAR(1000),
		C_COLUMNDATATYPE                   VARCHAR(50),
		AGG_TYPE                           VARCHAR(50),
		CONSTRAIN_BY_DATE_TO               DATE,
		CONSTRAIN_BY_DATE_FROM             DATE,
		CONSTRAIN_BY_VALUE_OPERATOR        VARCHAR(20),
		CONSTRAIN_BY_VALUE_CONSTRAINT      VARCHAR(1000),
		CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE VARCHAR(50),
		CONSTRAIN_BY_VALUE_TYPE            VARCHAR(50),
		CONSTRAIN_BY_INDEXDATE_COLUMNNAME  VARCHAR(1000),
		CONSTRAIN_BY_INDEXDATE_FROM_DAYS   INTEGER,
		CONSTRAIN_BY_INDEXDATE_TO_DAYS     INTEGER,
		USE_AS_COHORT                      CHAR(1)
	) ON COMMIT PRESERVE ROWS;
EXCEPTION
    WHEN duplicate_table THEN
        -- Table already exists
        TRUNCATE TABLE TMP_COLUMN_DEFINITIONS;
    	--RAISE NOTICE 'Temporary table TMP_COLUMN_DEFINITIONS already exists.'; -- Optional: Log or notify
END;

BEGIN
	-- Temporary table: TMP_RESULTS_TALL
	CREATE TEMPORARY TABLE TMP_RESULTS_TALL (
		PATIENT_NUM INTEGER,
		COL         VARCHAR(400),
		VAL         VARCHAR(400)
	) ON COMMIT PRESERVE ROWS;
EXCEPTION
    WHEN duplicate_table THEN
        -- Table already exists
        TRUNCATE TABLE TMP_RESULTS_TALL;
        --RAISE NOTICE 'Temporary table TMP_RESULTS_TALL already exists.'; -- Optional: Log or notify
END;
    
    -- Populate TMP_COLUMN_DEFINITIONS from RPDO_TABLE_REQUEST
    INSERT INTO TMP_COLUMN_DEFINITIONS (
        TABLE_INSTANCE_NAME,
        USER_ID,
        GROUP_ID,
        SET_INDEX,
        C_FACTTABLECOLUMN,
        C_TABLENAME,
        C_FULLPATH,
        C_COLUMNNAME,
        COLUMN_NAME,
        C_OPERATOR,
        C_DIMCODE,
        C_COLUMNDATATYPE,
        AGG_TYPE,
        CONSTRAIN_BY_DATE_TO,
        CONSTRAIN_BY_DATE_FROM,
        CONSTRAIN_BY_VALUE_OPERATOR,
        CONSTRAIN_BY_VALUE_CONSTRAINT,
        CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
        CONSTRAIN_BY_VALUE_TYPE,
        CONSTRAIN_BY_INDEXDATE_COLUMNNAME,
        CONSTRAIN_BY_INDEXDATE_FROM_DAYS,
        CONSTRAIN_BY_INDEXDATE_TO_DAYS,
        USE_AS_COHORT
    )
    SELECT
        TABLE_INSTANCE_NAME,
        USER_ID,
        GROUP_ID,
        SET_INDEX,
        C_FACTTABLECOLUMN,
        C_TABLENAME,
        C_FULLPATH,
        C_COLUMNNAME,
        COLUMN_NAME,
        C_OPERATOR,
        C_DIMCODE,
        C_COLUMNDATATYPE,
        AGG_TYPE,
        CONSTRAIN_BY_DATE_TO,
        CONSTRAIN_BY_DATE_FROM,
        CONSTRAIN_BY_VALUE_OPERATOR,
        CONSTRAIN_BY_VALUE_CONSTRAINT,
        CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE,
        CONSTRAIN_BY_VALUE_TYPE,
        CONSTRAIN_BY_INDEXDATE_COLUMNNAME,
        CONSTRAIN_BY_INDEXDATE_FROM_DAYS,
        CONSTRAIN_BY_INDEXDATE_TO_DAYS,
        USE_AS_COHORT
    FROM RPDO_TABLE_REQUEST
    WHERE TABLE_INSTANCE_ID = p_table_instance_id
    AND DELETE_FLAG = 'N' AND C_VISUALATTRIBUTES LIKE '_A_' 
    ORDER BY SET_INDEX;
    
    -- Get patient set SQL from udf_patientset_sql
    v_patientset_sql := udf_patientset_sql(p_result_instance_id, p_min_row, p_max_row, p_table_instance_id);
    
    -- Determine maximum SET_INDEX
    SELECT COALESCE(MAX(SET_INDEX), 0) INTO v_max_set_index FROM TMP_COLUMN_DEFINITIONS;
    
    -- Loop over each SET_INDEX and build column SQL via udf_rpdo_column_sql
    FOR v_tmp_row IN SELECT * FROM TMP_COLUMN_DEFINITIONS ORDER BY set_index LOOP
    -- Call column_sql with v_tmp_row fields


    /*WHILE v_set_index <= v_max_set_index LOOP
        SELECT * INTO v_tmp_row FROM TMP_COLUMN_DEFINITIONS WHERE SET_INDEX = v_set_index;*/
        
        -- Print debugging information
        RAISE NOTICE E'Calling udf_rpdo_column_sql with:\n
  p_patientset_sql: %\n
  p_column_name: %\n
  p_c_facttablecolumn: %\n
  p_c_tablename: %\n
  p_c_columnname: %\n
  p_c_columndatatype: %\n
  p_c_dimcode: %\n
  p_c_operator: %\n
  p_agg_type: %\n
  p_table_instance_id: %\n
  p_constrain_by_date_to: %\n
  p_constrain_by_date_from: %\n
  p_constrain_by_value_operator: %\n
  p_constrain_by_value_constraint: %\n
  p_constrain_by_value_unit_of_measure: %\n
  p_constrain_by_value_type: %\n
  p_constrain_by_indexdate_columnname: %\n
  p_constrain_by_indexdate_from_days: %\n
  p_constrain_by_indexdate_to_days: %',
  v_patientset_sql,
  v_tmp_row.c_columnname,
  v_tmp_row.c_facttablecolumn,
  COALESCE(v_tmp_row.c_tablename, 'patient_dimension'),
  v_tmp_row.c_columnname,
  v_tmp_row.c_columndatatype,
  v_tmp_row.c_dimcode,
  v_tmp_row.c_operator,
  COALESCE(v_tmp_row.agg_type, 'Value'),
  p_table_instance_id,
  CASE WHEN v_tmp_row.constrain_by_date_to IS NOT NULL THEN to_char(v_tmp_row.constrain_by_date_to, 'YYYY-MM-DD') ELSE NULL END,
  CASE WHEN v_tmp_row.constrain_by_date_from IS NOT NULL THEN to_char(v_tmp_row.constrain_by_date_from, 'YYYY-MM-DD') ELSE NULL END,
  v_tmp_row.constrain_by_value_operator,
  v_tmp_row.constrain_by_value_constraint,
  v_tmp_row.constrain_by_value_unit_of_measure,
  v_tmp_row.constrain_by_value_type,
  v_tmp_row.constrain_by_indexdate_columnname,
  v_tmp_row.constrain_by_indexdate_from_days,
  v_tmp_row.constrain_by_indexdate_to_days;

        
        v_column_sql := udf_rpdo_column_sql(
            v_patientset_sql,                                                   -- p_patientset_sql
            v_tmp_row.column_name,                                             -- p_column_name
            v_tmp_row.c_facttablecolumn,                                        -- p_c_facttablecolumn
            COALESCE(v_tmp_row.c_tablename, 'patient_dimension'),               -- p_c_tablename
            v_tmp_row.c_columnname,                                             -- p_c_columnname (literal)
            v_tmp_row.c_columndatatype,                                         -- p_c_columndatatype
            v_tmp_row.c_dimcode,                                                -- p_c_dimcode
            v_tmp_row.c_operator,                                               -- p_c_operator
            COALESCE(v_tmp_row.agg_type, 'Value'),                              -- p_agg_type
            p_table_instance_id,                                                -- p_table_instance_id
            CASE WHEN v_tmp_row.constrain_by_date_to IS NOT NULL THEN to_char(v_tmp_row.constrain_by_date_to, 'YYYY-MM-DD') ELSE NULL END,  -- p_constrain_by_date_to
            CASE WHEN v_tmp_row.constrain_by_date_from IS NOT NULL THEN to_char(v_tmp_row.constrain_by_date_from, 'YYYY-MM-DD') ELSE NULL END,  -- p_constrain_by_date_from
            v_tmp_row.constrain_by_value_operator,                              -- p_constrain_by_value_operator
            v_tmp_row.constrain_by_value_constraint,                            -- p_constrain_by_value_constraint
            v_tmp_row.constrain_by_value_unit_of_measure,                       -- p_constrain_by_value_unit_of_measure
            v_tmp_row.constrain_by_value_type,                                  -- p_constrain_by_value_type
            v_tmp_row.constrain_by_indexdate_columnname,                        -- p_constrain_by_indexdate_columnname
            v_tmp_row.constrain_by_indexdate_from_days,                         -- p_constrain_by_indexdate_from_days
            v_tmp_row.constrain_by_indexdate_to_days                            -- p_constrain_by_indexdate_to_days
        );
        
        -- Use COALESCE to ensure the dynamic SQL string is not null
        v_column_sql := COALESCE(v_column_sql, '');
        
        IF trim(v_column_sql) = '' THEN
            RAISE NOTICE 'Dynamic SQL is empty for SET_INDEX %', v_set_index;
        ELSE
            UPDATE RPDO_TABLE_REQUEST
            SET GENERATED_SQL = v_column_sql
            WHERE TABLE_INSTANCE_ID = p_table_instance_id AND SET_INDEX = v_set_index;
            
            RAISE NOTICE 'Executing dynamic SQL: %', v_column_sql;
            FOR rec IN EXECUTE v_column_sql LOOP
                INSERT INTO TMP_RESULTS_TALL (PATIENT_NUM, COL, VAL)
                VALUES (rec.patient_num, rec.col, rec.val);
            END LOOP;
        END IF;
        
        v_set_index := v_set_index + 1;
    END LOOP;
    
    -- Build the SELECT column list for pivot (using conditional aggregation)	
	SELECT string_agg(
	  'COALESCE(MAX(CASE WHEN col = ''' || column_name || ''' THEN val END)::text, ' ||
	  CASE
		WHEN agg_type = 'Exists' THEN '''No'''
		WHEN agg_type LIKE 'Num%' THEN '''0'''
		ELSE ''''''
	  END ||
	  ') AS "' || column_name || '_' || SET_INDEX || '"', ', ')
	  --') AS "' || c_columnname || '"', ', ')
	INTO v_select_col
	FROM (SELECT DISTINCT SET_INDEX, column_name, agg_type FROM TMP_COLUMN_DEFINITIONS) t;

    v_pivot_sql := 'SELECT patient_num, ' || v_select_col || ' FROM (' ||
                   ' SELECT p.patient_num, ce.col, ce.val ' ||
                   ' FROM (' || v_patientset_sql || ') p ' ||
                   ' CROSS JOIN TMP_COLUMN_DEFINITIONS t ' ||
                   ' LEFT JOIN TMP_RESULTS_TALL ce ON ce.col = t.column_name AND p.patient_num = ce.patient_num' ||
                   ') sub GROUP BY patient_num';

                   
    RAISE NOTICE 'usp_rpdo2: Final pivot SQL: %',v_pivot_sql;
		-- Step: Drop the temp table if it already exists

	-- Step: Create temp table with dynamic pivot SQL
	--EXECUTE 'DROP TABLE IF EXISTS tmp_pivot_results';
	--EXECUTE format('CREATE TEMP TABLE tmp_pivot_results AS %s', v_pivot_sql);

    -- Return the cursor
    OPEN cur FOR EXECUTE v_pivot_sql;
    --RETURN cur;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$body$
LANGUAGE plpgsql;
