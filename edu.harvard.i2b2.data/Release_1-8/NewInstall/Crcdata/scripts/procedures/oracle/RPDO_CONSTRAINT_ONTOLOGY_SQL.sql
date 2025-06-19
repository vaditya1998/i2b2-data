create or replace FUNCTION udf_constraint_ontology_sql (
    p_C_OPERATOR       IN VARCHAR2,
    p_C_COLUMNNAME     IN VARCHAR2,
    p_C_COLUMNDATATYPE IN VARCHAR2,
    p_C_DIMCODE        IN VARCHAR2
) RETURN CLOB
IS
    v_SQLConstraint CLOB := '';
BEGIN
    DBMS_OUTPUT.PUT_LINE('>>> udf_constraint_ontology_sql called');
    DBMS_OUTPUT.PUT_LINE('Operator: ' || p_C_OPERATOR);
    DBMS_OUTPUT.PUT_LINE('Column: ' || p_C_COLUMNNAME);
    DBMS_OUTPUT.PUT_LINE('Datatype: ' || p_C_COLUMNDATATYPE);
    DBMS_OUTPUT.PUT_LINE('Dimcode: ' || p_C_DIMCODE);

    IF p_C_OPERATOR = 'LIKE' THEN
        v_SQLConstraint := p_C_COLUMNNAME || ' LIKE ''' || REPLACE(p_C_DIMCODE, '''', '''''') || '%''';

    ELSIF p_C_OPERATOR IN ('>', '>=', '=', '<>', '<', '<=', 'BETWEEN') THEN
        IF p_C_COLUMNDATATYPE = 'N' THEN
            v_SQLConstraint := p_C_COLUMNNAME || ' ' || p_C_OPERATOR || ' ' || p_C_DIMCODE;
        ELSE
            v_SQLConstraint := p_C_COLUMNNAME || ' ' || p_C_OPERATOR || ' ''' || REPLACE(p_C_DIMCODE, '''', '''''') || '''';
        END IF;

    ELSIF p_C_OPERATOR = 'IN' THEN
        v_SQLConstraint := p_C_COLUMNNAME || ' IN (' || p_C_DIMCODE || ')';
    ELSE
        v_SQLConstraint := '-- Unsupported operator: ' || p_C_OPERATOR;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Generated Ontology SQL: ' || v_SQLConstraint);
    RETURN v_SQLConstraint;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in udf_constraint_ontology_sql: ' || SQLERRM);
        RETURN '-- Error: ' || SQLERRM;
END udf_constraint_ontology_sql;


