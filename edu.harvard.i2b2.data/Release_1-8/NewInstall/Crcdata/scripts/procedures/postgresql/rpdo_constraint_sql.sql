CREATE OR REPLACE FUNCTION udf_constraint_sql(
    p_c_tablename                        TEXT,
    p_constrain_by_date_from             TEXT,
    p_constrain_by_date_to               TEXT,
    p_constrain_by_value_operator        TEXT,
    p_constrain_by_value_constraint      TEXT,
    p_constrain_by_value_unit_of_measure TEXT,
    p_constrain_by_value_type            TEXT
) RETURNS TEXT AS $body$
DECLARE
    v_sqlconstraint TEXT := '';
    v_operator TEXT := p_constrain_by_value_operator;
    v_constrain_by_value_constraint TEXT := p_constrain_by_value_constraint;
BEGIN
    IF p_constrain_by_date_from IS NOT NULL AND trim(p_constrain_by_date_from) <> '' THEN
        v_sqlconstraint := v_sqlconstraint ||
           ' AND DATE(START_DATE) >= TO_DATE(''' || p_constrain_by_date_from || ''',''MM/DD/YYYY HH24:MI'')';
    END IF;
    IF p_constrain_by_date_to IS NOT NULL AND trim(p_constrain_by_date_to) <> '' THEN
        v_sqlconstraint := v_sqlconstraint ||
           ' AND DATE(START_DATE) <= TO_DATE(''' || p_constrain_by_date_to || ''',''MM/DD/YYYY HH24:MI'')';
    END IF;
    IF p_c_tablename = 'concept_dimension' THEN
        IF upper(p_constrain_by_value_type) = 'NUMBER' THEN
            IF upper(v_operator) = 'EQ' THEN
                v_operator := '=';
            ELSIF upper(v_operator) = 'NE' THEN
                v_operator := '<>';
            ELSIF upper(v_operator) = 'GT' THEN
                v_operator := '>';
            ELSIF upper(v_operator) = 'GE' THEN
                v_operator := '>=';
            ELSIF upper(v_operator) = 'LT' THEN
                v_operator := '<';
            ELSIF upper(v_operator) = 'LE' THEN
                v_operator := '<=';
            END IF;
            v_sqlconstraint := v_sqlconstraint ||
               ' AND NVAL_NUM ' || v_operator || ' ' || p_constrain_by_value_constraint;
        ELSIF upper(p_constrain_by_value_type) = 'ENUM' THEN
            IF upper(v_operator) = 'LIKE' THEN
				v_sqlconstraint := v_sqlconstraint ||
				   ' AND TVAL_CHAR LIKE ''%' || replace(p_constrain_by_value_constraint, E'\\', E'\\\\') || '%'' ESCAPE ''\\''';
            ELSIF upper(v_operator) = 'IN' THEN
                v_sqlconstraint := v_sqlconstraint ||
                   ' AND TVAL_CHAR IN ' || p_constrain_by_value_constraint;
            END IF;
        ELSIF upper(p_constrain_by_value_type) = 'TEXT' THEN
        
        -- assume `constrain_by_value_constraint` is a TEXT variable
			v_constrain_by_value_constraint := REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								p_constrain_by_value_constraint,
								'''',  ''''''    -- single quote → two single quotes
							),
							E'\\', E'\\\\'   -- backslash → two backslashes
						),
						E'%',  E'\\%'     -- percent → \%
					),
					E'_',  E'\\_'       -- underscore → \_
				),
				E'[',  E'\\['         -- bracket → \[
			);


            IF upper(v_operator) = 'IN' THEN
                v_sqlconstraint := v_sqlconstraint ||
                   ' AND TVAL_CHAR IN (' || v_constrain_by_value_constraint || ')';
            ELSIF upper(v_operator) = 'LIKE[EXACT]' THEN
			   v_sqlconstraint := v_sqlconstraint ||
        			' AND TVAL_CHAR = ''' || v_constrain_by_value_constraint || ''''; -- Changed to '=' for exact match
            ELSIF upper(v_operator) = 'LIKE[END]' THEN
                v_sqlconstraint := v_sqlconstraint ||
                   ' AND TVAL_CHAR LIKE ''%' || v_constrain_by_value_constraint || '''';
            ELSIF upper(v_operator) = 'LIKE[BEGIN]' THEN
                v_sqlconstraint := v_sqlconstraint ||
                   ' AND TVAL_CHAR LIKE ''' || v_constrain_by_value_constraint || '%''';
            ELSIF upper(v_operator) = 'LIKE[CONTAINS]' THEN
                v_sqlconstraint := v_sqlconstraint ||
                   ' AND TVAL_CHAR LIKE ''%' || v_constrain_by_value_constraint || '%''';
            END IF;
        ELSIF upper(p_constrain_by_value_type) = 'FLAG' THEN
            v_sqlconstraint := v_sqlconstraint ||
               ' AND VALUEFLAG_CD ' || p_constrain_by_value_operator || ' ''' || p_constrain_by_value_constraint || '''';
        ELSIF upper(p_constrain_by_value_type) = 'LARGETEXT' THEN
            IF upper(v_operator) = 'CONTAINS' THEN
                v_sqlconstraint := v_sqlconstraint ||
                   ' AND CONTAINS(OBSERVATION_BLOB, ''' || p_constrain_by_value_constraint || ''')';
            END IF;
        END IF;
    END IF;
    RETURN v_sqlconstraint;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$body$ 
LANGUAGE plpgsql;
