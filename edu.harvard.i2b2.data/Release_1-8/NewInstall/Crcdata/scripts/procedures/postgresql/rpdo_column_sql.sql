CREATE OR REPLACE FUNCTION udf_rpdo_column_sql_dev(
    patient_set_sql                    TEXT,
    column_name                        TEXT,
    c_facttablecolumn                  TEXT,
    c_tablename                        TEXT,
    c_columnname                       TEXT,
    c_columndatatype                   TEXT,
    c_dimcode                          TEXT,
    c_operator                         TEXT,
    agg_type                           TEXT,
    table_instance_id                  INTEGER,
    constrain_by_date_to               TEXT    DEFAULT NULL,
    constrain_by_date_from             TEXT    DEFAULT NULL,
    constrain_by_value_operator        TEXT    DEFAULT NULL,
    constrain_by_value_constraint      TEXT    DEFAULT NULL,
    constrain_by_value_unit_of_measure TEXT    DEFAULT NULL,
    constrain_by_value_type            TEXT    DEFAULT NULL,
    constrain_by_indexdate_columnname  TEXT    DEFAULT NULL,
    constrain_by_indexdate_from_days   INTEGER DEFAULT NULL,
    constrain_by_indexdate_to_days     INTEGER DEFAULT NULL
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
    constraint_sql           TEXT;
    indexdate_constraint_sql TEXT := '';
    ontology_constraint_sql  TEXT;
    aggregation_sql          TEXT;
    rpdo_column_sql          TEXT;
    base_facttable           TEXT := 'observation_fact';
BEGIN
    ----------------------------------------------------------------
    -- Short‐circuit for patient_dimension with Value agg_type
    ----------------------------------------------------------------
    IF c_tablename = 'patient_dimension'
       AND agg_type = 'Value'
    THEN
        IF c_columndatatype = 'N' THEN
            rpdo_column_sql := format(
              'SELECT patient_num, %L AS col, %s AS val
               FROM patient_dimension
               WHERE patient_num IN (%s)',
              column_name,
              c_facttablecolumn,
              patient_set_sql
            );
            RETURN rpdo_column_sql;

        ELSIF c_columndatatype IN ('T','S') THEN
            rpdo_column_sql := format(
              'SELECT patient_num, %L AS col, (%s)::TEXT AS val
               FROM patient_dimension
               WHERE patient_num IN (%s)',
              column_name,
              c_facttablecolumn,
              patient_set_sql
            );
            RETURN rpdo_column_sql;

        ELSIF c_columndatatype = 'D' THEN
            rpdo_column_sql := format(
              'SELECT patient_num, %L AS col, to_char(%s, ''YYYY-MM-DD'') AS val
               FROM patient_dimension
               WHERE patient_num IN (%s)',
              column_name,
              c_facttablecolumn,
              patient_set_sql
            );
            RETURN rpdo_column_sql;

        ELSE
            rpdo_column_sql := format(
              'SELECT patient_num, %L AS col, (%s)::TEXT AS val
               FROM patient_dimension
               WHERE patient_num IN (%s)',
              column_name,
              c_facttablecolumn,
              patient_set_sql
            );
            RETURN rpdo_column_sql;
        END IF;

    ----------------------------------------------------------------
    -- Short‐circuit for QT_PATIENT_SET_COLLECTION Exists
    ----------------------------------------------------------------
    ELSIF c_tablename = 'qt_patient_set_collection'
       AND agg_type = 'Exists'
    THEN
        rpdo_column_sql := format(
          'SELECT patient_num, %L AS col, ''Yes'' AS val
           FROM qt_patient_set_collection
           WHERE result_instance_id = %s
             AND patient_num IN (%s)',
          column_name,
          c_dimcode,
          patient_set_sql
        );
        RETURN rpdo_column_sql;
    END IF;

    ----------------------------------------------------------------
    -- General case: build constraint, ontology, aggregation SQL
    ----------------------------------------------------------------
    constraint_sql          := udf_constraint_sql(
                                 c_tablename,
                                 constrain_by_date_to,
                                 constrain_by_date_from,
                                 constrain_by_value_operator,
                                 constrain_by_value_constraint,
                                 constrain_by_value_unit_of_measure,
                                 constrain_by_value_type
                               );
    ontology_constraint_sql := udf_constraint_ontology_sql(
                                 c_operator,
                                 c_columnname,
                                 c_columndatatype,
                                 c_dimcode
                               );
    aggregation_sql         := udf_aggregation_sql(agg_type);

    IF constrain_by_indexdate_columnname IS NOT NULL THEN
      indexdate_constraint_sql := udf_indexdate_constraint_sql(
                                   table_instance_id,
                                   constrain_by_indexdate_columnname,
                                   constrain_by_indexdate_from_days,
                                   constrain_by_indexdate_to_days
                                 );
    END IF;

    ----------------------------------------------------------------
    -- Support multi‐fact tables (schema.table.col => table and col)
    ----------------------------------------------------------------
    IF position('.' IN c_facttablecolumn) > 0 THEN
        base_facttable     := split_part(c_facttablecolumn, '.', 1);
        c_facttablecolumn  := replace(
                                c_facttablecolumn,
                                base_facttable || '.',
                                ''
                              );
    END IF;

    ----------------------------------------------------------------
    -- Start the CTE based on the dimension
    ----------------------------------------------------------------
    IF c_tablename = 'concept_dimension' THEN
        rpdo_column_sql := 'WITH t AS (
                               SELECT DISTINCT
                                 patient_num,
                                 encounter_num,
                                 concept_cd,
                                 start_date,
                                 provider_id,
                                 tval_char,
                                 nval_num
                            ';

    ELSIF c_tablename = 'patient_dimension' THEN
        rpdo_column_sql := 'WITH t AS (
                               SELECT patient_num
                            ';

    ELSIF c_tablename = 'visit_dimension' THEN
        rpdo_column_sql := format(
                              'WITH t AS (
                                 SELECT DISTINCT
                                   patient_num,
                                   encounter_num,
                                   start_date,
                                   %s
                              ',
                              c_facttablecolumn
                            );

    ELSE
        rpdo_column_sql := format(
                              'WITH t AS (
                                 SELECT DISTINCT
                                   patient_num,
                                   %s
                              ',
                              c_facttablecolumn
                            );
    END IF;

    ----------------------------------------------------------------
    -- Add FROM clause, ontology filter, date/value constraints
    ----------------------------------------------------------------
    rpdo_column_sql := rpdo_column_sql || format(
      'FROM %I f
       WHERE f.patient_num IN (%s)
         AND f.%I IN (
             SELECT %I
               FROM %I
              WHERE %s
           )
       %s
      ) ',
      base_facttable,
      patient_set_sql,
      c_facttablecolumn,
      c_facttablecolumn,
      c_tablename,
      ontology_constraint_sql,
      constraint_sql,
      indexdate_constraint_sql
    );

    ----------------------------------------------------------------
    -- Append final SELECT based on aggregation type
    ----------------------------------------------------------------
    IF agg_type LIKE 'Multi%' THEN
        rpdo_column_sql := rpdo_column_sql || aggregation_sql;
    ELSE
        rpdo_column_sql := rpdo_column_sql || format(
          'SELECT DISTINCT patient_num, %L AS col, %s',
          column_name,
          aggregation_sql
        );
    END IF;

    RETURN rpdo_column_sql;
END;
$$;
