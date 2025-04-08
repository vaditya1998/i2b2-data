CREATE OR REPLACE FUNCTION udf_rpdo_column_sql_dev(
    p_patientset_sql                     TEXT,
    p_column_name                        TEXT,
    p_c_facttablecolumn                  TEXT,
    p_c_tablename                        TEXT,
    p_c_columnname                       TEXT,
    p_c_columndatatype                   TEXT,
    p_c_dimcode                          TEXT,
    p_c_operator                         TEXT,
    p_agg_type                           TEXT,
    p_table_instance_id                  INTEGER,
    p_constrain_by_date_to               TEXT DEFAULT NULL,
    p_constrain_by_date_from             TEXT DEFAULT NULL,
    p_constrain_by_value_operator        TEXT DEFAULT NULL,
    p_constrain_by_value_constraint      TEXT DEFAULT NULL,
    p_constrain_by_value_unit_of_measure TEXT DEFAULT NULL,
    p_constrain_by_value_type            TEXT DEFAULT NULL,
    p_constrain_by_indexdate_columnname  TEXT DEFAULT NULL,
    p_constrain_by_indexdate_from_days   INTEGER DEFAULT NULL,
    p_constrain_by_indexdate_to_days     INTEGER DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    v_rpdo_column_sql           TEXT;
    v_constraint_sql            TEXT;
    v_indexdate_constraint_sql  TEXT := '';
    v_ontology_constraint_sql   TEXT;
    v_aggregation_sql           TEXT;
    v_c_facttable               TEXT := 'observation_fact';
    v_c_facttablecolumn_local   TEXT := p_c_facttablecolumn;
BEGIN
    -- Add this branch immediately after variable declarations:
    /*IF p_agg_type = 'Value' THEN
        v_rpdo_column_sql :=
            'select patient_num, ''' ||
            CASE 
              WHEN trim(p_column_name) = '' THEN 'Default'
              ELSE replace(p_column_name, '''', '''''')
            END ||
            ''' as col, TO_CHAR(' || p_c_facttablecolumn || ', ''YYYY-MM-DD'') as val from patient_dimension ' ||
            'where patient_num IN (' || p_patientset_sql || ')';
        RETURN v_rpdo_column_sql;
    END IF;*/
    RAISE NOTICE 'tab % agg %',p_c_tablename,p_agg_type

    IF p_c_tablename = 'patient_dimension' AND p_agg_type = 'Value' THEN
        v_rpdo_column_sql :=
            'select patient_num, ''' || p_column_name || ''' as col, ' ||
            'TO_CHAR(' || p_c_facttablecolumn || ', ''YYYY-MM-DD'') as val from patient_dimension ' ||
            'where patient_num IN (' || p_patientset_sql || ')';
    	RAISE NOTICE 'patdimcol %', v_rpdo_column_sql;
    
    ELSIF p_c_tablename = 'qt_patient_set_collection' AND p_agg_type = 'Exists' THEN
        v_rpdo_column_sql :=
            'select patient_num, ''' || p_column_name || ''' as col, ''Yes'' as val from qt_patient_set_collection ' ||
            'where RESULT_INSTANCE_ID = ' || p_c_dimcode || ' AND patient_num IN (' || p_patientset_sql || ')';
    ELSE
        v_constraint_sql := udf_constraint_sql(
            p_c_tablename,
            p_constrain_by_date_from,
            p_constrain_by_date_to,
            p_constrain_by_value_operator,
            p_constrain_by_value_constraint,
            p_constrain_by_value_unit_of_measure,
            p_constrain_by_value_type
        );
        v_ontology_constraint_sql := udf_constraint_ontology_sql(
            p_c_operator,
            p_c_columnname,
            p_c_columndatatype,
            p_c_dimcode
        );
        v_aggregation_sql := udf_aggregation_sql(p_agg_type);
        IF p_constrain_by_indexdate_columnname IS NOT NULL THEN
            v_indexdate_constraint_sql := udf_indexdate_constraint_sql(
                                              p_table_instance_id,
                                              p_constrain_by_indexdate_columnname,
                                              p_constrain_by_indexdate_from_days,
                                              p_constrain_by_indexdate_to_days
                                          );
        END IF;
        IF position('.' in v_c_facttablecolumn_local) > 0 THEN
            v_c_facttable := substring(v_c_facttablecolumn_local from 1 for position('.' in v_c_facttablecolumn_local)-1);
            v_c_facttablecolumn_local := replace(v_c_facttablecolumn_local, v_c_facttable || '.', '');
        END IF;
        IF p_c_tablename = 'concept_dimension' THEN
            v_rpdo_column_sql := 'with t as (select distinct patient_num, encounter_num, concept_cd, start_date, provider_id, tval_char, nval_num ';
        ELSIF p_c_tablename = 'patient_dimension' THEN
            v_rpdo_column_sql := 'with t as (select patient_num ';
        ELSIF p_c_tablename = 'visit_dimension' THEN
            v_rpdo_column_sql := 'with t as (select distinct patient_num, encounter_num, start_date, ' || v_c_facttablecolumn_local || ' ';
        ELSE
            v_rpdo_column_sql := 'with t as (select * ';
        END IF;
        
		-- Build the FROM clause and subquery; if p_c_tablename is empty, skip the IN subquery.
		IF trim(COALESCE(p_c_tablename, '')) = '' THEN
			v_rpdo_column_sql := v_rpdo_column_sql ||
				'from ' || v_c_facttable || ' f ' ||
				'where patient_num IN (' || p_patientset_sql || ') ' ||
				v_constraint_sql || v_indexdate_constraint_sql || ') ';
		ELSE
			v_rpdo_column_sql := v_rpdo_column_sql ||
				'from ' || v_c_facttable || ' f ' ||
				'where patient_num IN (' || p_patientset_sql || ') and f.' || v_c_facttablecolumn_local || ' IN (' ||
					'select ' || v_c_facttablecolumn_local || ' from ' || p_c_tablename || ' where ' || v_ontology_constraint_sql || ') ' ||
					v_constraint_sql || v_indexdate_constraint_sql || ') ';
		END IF;


                
		IF left(p_agg_type, 5) = 'Multi' THEN
			v_rpdo_column_sql := v_rpdo_column_sql || 'select distinct patient_num, ' || COALESCE(v_aggregation_sql, '');
		ELSE
			v_rpdo_column_sql := v_rpdo_column_sql ||
				'select distinct patient_num, ''' ||
				CASE 
				  WHEN trim(p_column_name) = '' THEN 'DEFAULT_COL' 
				  ELSE replace(p_column_name, '''', '''''') 
				END ||
				''' as col, ' || v_aggregation_sql;
		END IF;
    END IF;
    RAISE NOTICE 'your col %', v_rpdo_column_sql;
    RETURN v_rpdo_column_sql;
END;
$$ LANGUAGE plpgsql;
