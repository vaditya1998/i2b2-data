/*
################################################################################
-- File:    usp_rpdo2.sql (Oracle version)
-- Purpose: Oracle PL/SQL procedure to generate pivoted custom tables for I2B2
--          query results, returning via REFCURSOR.
--
-- Invocation (SQL*Plus / SQL Developer):
--   -- 1. Load the script:
--      @/path/to/usp_rpdo2_oracle.sql
--
--   -- 2. Bind and call (for example):
--      VAR rc REFCURSOR;
--      EXEC usp_rpdo2(
--        p_table_instance_id  => 322,
--        p_result_instance_id => 1333,
--        p_min_row            => 1,
--        p_max_row            => 10,
--        p_refcursor          => :rc
--      );
--
--   -- 3. View results:
--      PRINT rc;
--
-- Notes:
--   - Uses a REF CURSOR OUT parameter named p_refcursor.
--   - Temporary cursors live for the duration of your session.
--
-- © 2025 Massachusetts General Hospital
################################################################################
*/

CREATE OR REPLACE PROCEDURE usp_rpdo2 (
    p_table_instance_id    IN  NUMBER,
    p_result_instance_id   IN  NUMBER DEFAULT NULL,
    p_min_row              IN  NUMBER DEFAULT NULL,
    p_max_row              IN  NUMBER DEFAULT NULL,
    p_refcursor            OUT SYS_REFCURSOR
) AS
    -- loop control
    v_set_index       NUMBER;
    v_max_set_index   NUMBER;
    -- SQL fragments
    v_patientset_sql  CLOB;
    v_column_sql      CLOB;
    v_full_sql        CLOB;
    v_pivot_cols      CLOB;
    v_pivot_sql       CLOB;
    -- per‑row values
    v_c_tablename                        VARCHAR2(50);
    v_column_name                        VARCHAR2(1000);
    v_c_fullpath                         VARCHAR2(700);
    v_agg_type                           VARCHAR2(50);
    v_constrain_by_date_to               VARCHAR2(100);
    v_constrain_by_date_from             VARCHAR2(100);
    v_constrain_by_value_operator        VARCHAR2(20);
    v_constrain_by_value_constraint      VARCHAR2(1000);
    v_constrain_by_value_unit_of_measure VARCHAR2(50);
    v_constrain_by_value_type            VARCHAR2(50);
    v_c_columnname                       VARCHAR2(30);
    v_c_columndatatype                   VARCHAR2(50);
    v_c_dimcode                          VARCHAR2(1000);
    v_c_operator                         VARCHAR2(30);
    v_c_facttablecolumn                  VARCHAR2(100);
    v_constrain_by_indexdate_columnname  VARCHAR2(1000);
    v_constrain_by_indexdate_from_days   NUMBER;
    v_constrain_by_indexdate_to_days     NUMBER;
BEGIN
    -- 1) Clear out the temp tables
    DELETE FROM tmp_column_definitions;
    DELETE FROM tmp_results_tall;

    -- 2) Load definitions from the request table
    INSERT INTO tmp_column_definitions
    SELECT
      table_instance_name,
      user_id,
      group_id,
      set_index,
      c_facttablecolumn,
      c_tablename,
      c_fullpath,
      c_columnname,
      c_operator,
      c_dimcode,
      c_columndatatype,
      column_name,
      agg_type,
      TO_CHAR(constrain_by_date_to,'YYYY-MM-DD'),
      TO_CHAR(constrain_by_date_from,'YYYY-MM-DD'),
      constrain_by_value_operator,
      constrain_by_value_constraint,
      constrain_by_value_unit_of_measure,
      constrain_by_value_type,
      constrain_by_indexdate_columnname,
      constrain_by_indexdate_from_days,
      constrain_by_indexdate_to_days,
      use_as_cohort
    FROM rpdo_table_request
    WHERE table_instance_id = p_table_instance_id;

    -- 3) Build the patient‐set SQL
    v_patientset_sql := udf_patientset_sql_dev(
      p_RESULT_INSTANCE_ID   => p_result_instance_id,
      p_MIN_ROW              => p_min_row,
      p_MAX_ROW              => p_max_row,
      p_TABLE_INSTANCE_ID    => p_table_instance_id
    );

    -- 4) Determine loop bounds
    SELECT MIN(set_index), MAX(set_index)
      INTO v_set_index, v_max_set_index
      FROM tmp_column_definitions;

    IF v_set_index IS NULL THEN
      -- no columns requested: return an empty cursor
      OPEN p_refcursor FOR SELECT NULL AS dummy FROM dual WHERE 1=0;
      RETURN;
    END IF;

    -- 5) Loop through each requested column
    WHILE v_set_index <= v_max_set_index LOOP
      -- fetch the parameters for this column
      SELECT
        c_tablename,
        column_name,
        c_fullpath,
        agg_type,
        constrain_by_date_to,
        constrain_by_date_from,
        constrain_by_value_operator,
        constrain_by_value_constraint,
        constrain_by_value_unit_of_measure,
        constrain_by_value_type,
        c_facttablecolumn,
        c_columnname,
        c_columndatatype,
        c_dimcode,
        c_operator,
        constrain_by_indexdate_columnname,
        constrain_by_indexdate_from_days,
        constrain_by_indexdate_to_days
      INTO
        v_c_tablename,
        v_column_name,
        v_c_fullpath,
        v_agg_type,
        v_constrain_by_date_to,
        v_constrain_by_date_from,
        v_constrain_by_value_operator,
        v_constrain_by_value_constraint,
        v_constrain_by_value_unit_of_measure,
        v_constrain_by_value_type,
        v_c_facttablecolumn,
        v_c_columnname,
        v_c_columndatatype,
        v_c_dimcode,
        v_c_operator,
        v_constrain_by_indexdate_columnname,
        v_constrain_by_indexdate_from_days,
        v_constrain_by_indexdate_to_days
      FROM tmp_column_definitions
      WHERE set_index = v_set_index;

      IF v_c_tablename IS NOT NULL THEN
        -- generate the per‐column SQL
        v_column_sql := udf_rpdo_column_sql_dev(
          p_patientset_sql                    => v_patientset_sql,
          p_column_name                       => v_column_name,
          p_c_facttablecolumn                 => v_c_facttablecolumn,
          p_c_tablename                       => v_c_tablename,
          p_c_columnname                      => v_c_columnname,
          p_c_columndatatype                  => v_c_columndatatype,
          p_c_dimcode                         => v_c_dimcode,
          p_c_operator                        => v_c_operator,
          p_agg_type                          => v_agg_type,
          p_table_instance_id                 => p_table_instance_id,
          p_constrain_by_date_to              => v_constrain_by_date_to,
          p_constrain_by_date_from            => v_constrain_by_date_from,
          p_constrain_by_value_operator       => v_constrain_by_value_operator,
          p_constrain_by_value_constraint     => v_constrain_by_value_constraint,
          p_constrain_by_value_unit_of_measure=> v_constrain_by_value_unit_of_measure,
          p_constrain_by_value_type           => v_constrain_by_value_type,
          p_constrain_by_indexdate_columnname => v_constrain_by_indexdate_columnname,
          p_constrain_by_indexdate_from_days  => v_constrain_by_indexdate_from_days,
          p_constrain_by_indexdate_to_days    => v_constrain_by_indexdate_to_days
        );

        -- insert the results of that dynamic SQL into the tall table
        v_full_sql := 'INSERT INTO tmp_results_tall(patient_num, col, val) ' 
                      || CHR(10) 
                      || v_column_sql;
        EXECUTE IMMEDIATE v_full_sql;

        -- store the generated SQL back for auditing
        UPDATE rpdo_table_request
           SET generated_sql = v_column_sql
         WHERE table_instance_id = p_table_instance_id
           AND set_index         = v_set_index;
      END IF;

      v_set_index := v_set_index + 1;
    END LOOP;

    -- 6) Build the pivot SQL and open the cursor
    SELECT LISTAGG(
             '''' || col || ''' AS "' ||
             SUBSTR(REGEXP_REPLACE(col, '[^A-Za-z0-9_]', '_'), 1, 30) || '"'
           , ',')
           WITHIN GROUP (ORDER BY col)
      INTO v_pivot_cols
      FROM (SELECT DISTINCT col FROM tmp_results_tall);

    v_pivot_sql :=
      'SELECT * FROM ( ' ||
      '  SELECT patient_num, col, val FROM tmp_results_tall ' ||
      ') PIVOT ( ' ||
      '  MAX(val) FOR col IN (' || v_pivot_cols || ') ' ||
      ')';

    OPEN p_refcursor FOR v_pivot_sql;
END usp_rpdo2;
/
