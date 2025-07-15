CREATE OR REPLACE FUNCTION udf_constraint_ontology_sql(
    p_c_operator       TEXT,
    p_c_columnname     TEXT,
    p_c_columndatatype TEXT,
    p_c_dimcode        TEXT
) RETURNS TEXT AS $body$
DECLARE
    v_sqlconstraint TEXT := '';
BEGIN
    IF p_c_operator = 'LIKE' THEN
		v_sqlconstraint := p_c_columnname || ' ' || p_c_operator || ' ''' ||
			replace(replace(p_c_dimcode, '''', ''''''), E'\\', E'\\\\') || '%'' ESCAPE ''\\''';

    ELSIF p_c_operator IN ('>', '>=', '=', '<>', '<', '<=', 'BETWEEN') THEN
        IF p_c_columndatatype = 'N' THEN
            v_sqlconstraint := p_c_columnname || ' ' || p_c_operator || ' ' || p_c_dimcode;
        ELSE
            v_sqlconstraint := p_c_columnname || ' ' || p_c_operator || ' ''' || p_c_dimcode || '''';
        END IF;
    ELSIF p_c_operator = 'IN' THEN
        v_sqlconstraint := p_c_columnname || ' ' || p_c_operator || ' (' || p_c_dimcode || ')';
    END IF;
    RETURN v_sqlconstraint;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$body$ LANGUAGE plpgsql;
