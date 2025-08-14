CREATE OR REPLACE FUNCTION udf_constraint_sql (
    p_C_TABLENAME                       IN VARCHAR2,
    p_CONSTRAIN_BY_DATE_FROM            IN VARCHAR2,
    p_CONSTRAIN_BY_DATE_TO              IN VARCHAR2,
    p_CONSTRAIN_BY_VALUE_OPERATOR       IN VARCHAR2,
    p_CONSTRAIN_BY_VALUE_CONSTRAINT     IN VARCHAR2,
    p_CONSTRAIN_BY_VALUE_UNIT_OF_MEASURE IN VARCHAR2,
    p_CONSTRAIN_BY_VALUE_TYPE           IN VARCHAR2
) RETURN CLOB
IS
    v_SQLConstraint CLOB := '';
    v_operator      VARCHAR2(20);
    v_escaped_value VARCHAR2(300);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- udf_constraint_sql called ---');
    DBMS_OUTPUT.PUT_LINE('C_TABLENAME = ' || NVL(p_C_TABLENAME, '<NULL>'));
    DBMS_OUTPUT.PUT_LINE('DATE_FROM = ' || NVL(p_CONSTRAIN_BY_DATE_FROM, '<NULL>'));
    DBMS_OUTPUT.PUT_LINE('DATE_TO = ' || NVL(p_CONSTRAIN_BY_DATE_TO, '<NULL>'));
    DBMS_OUTPUT.PUT_LINE('VALUE_OPERATOR = ' || NVL(p_CONSTRAIN_BY_VALUE_OPERATOR, '<NULL>'));
    DBMS_OUTPUT.PUT_LINE('VALUE_CONSTRAINT = ' || NVL(p_CONSTRAIN_BY_VALUE_CONSTRAINT, '<NULL>'));
    DBMS_OUTPUT.PUT_LINE('VALUE_TYPE = ' || NVL(p_CONSTRAIN_BY_VALUE_TYPE, '<NULL>'));

    IF p_CONSTRAIN_BY_DATE_FROM IS NOT NULL THEN
        v_SQLConstraint := v_SQLConstraint
            || ' AND START_DATE >= TO_DATE(''' || p_CONSTRAIN_BY_DATE_FROM || ''', ''YYYY-MM-DD'')';
    END IF;

    IF p_CONSTRAIN_BY_DATE_TO IS NOT NULL THEN
        v_SQLConstraint := v_SQLConstraint
            || ' AND START_DATE <= TO_DATE(''' || p_CONSTRAIN_BY_DATE_TO || ''', ''YYYY-MM-DD'')';
    END IF;

    IF p_C_TABLENAME = 'concept_dimension' THEN
        -- NUMBER
        IF p_CONSTRAIN_BY_VALUE_TYPE = 'NUMBER' THEN
            v_operator := CASE p_CONSTRAIN_BY_VALUE_OPERATOR
                            WHEN 'EQ' THEN '='
                            WHEN 'NE' THEN '<>'
                            WHEN 'GT' THEN '>'
                            WHEN 'GE' THEN '>='
                            WHEN 'LT' THEN '<'
                            WHEN 'LE' THEN '<='
                            ELSE p_CONSTRAIN_BY_VALUE_OPERATOR
                          END;
            v_SQLConstraint := v_SQLConstraint
                || ' AND NVAL_NUM ' || v_operator || ' ' || p_CONSTRAIN_BY_VALUE_CONSTRAINT;

        -- ENUM
        ELSIF p_CONSTRAIN_BY_VALUE_TYPE = 'ENUM' THEN
            IF p_CONSTRAIN_BY_VALUE_OPERATOR = 'IN' THEN
                -- Expecting something like "('A','B','C')"
                v_SQLConstraint := v_SQLConstraint
                    || ' AND TVAL_CHAR IN ' || p_CONSTRAIN_BY_VALUE_CONSTRAINT;
            ELSE
                v_SQLConstraint := v_SQLConstraint
                    || ' AND TVAL_CHAR = ''' || p_CONSTRAIN_BY_VALUE_CONSTRAINT || '''';
            END IF;

        -- TEXT (with escaping + ESCAPE clause)
        ELSIF p_CONSTRAIN_BY_VALUE_TYPE = 'TEXT' THEN
            v_escaped_value := REPLACE(
                                  REPLACE(
                                    REPLACE(
                                      REPLACE(
                                        REPLACE(p_CONSTRAIN_BY_VALUE_CONSTRAINT, '''', ''''''), -- ' -> ''
                                        '\', '\\' ),                                            -- \ -> \\
                                      '%', '\%' ),                                              -- % -> \%
                                    '_', '\_' ),                                                -- _ -> \_
                                  '[', '\[' );                                                  -- [ -> \[
            v_operator := NVL(p_CONSTRAIN_BY_VALUE_OPERATOR, 'LIKE[contains]');
            IF     v_operator = 'LIKE[exact]' THEN
                v_SQLConstraint := v_SQLConstraint
                    || ' AND TVAL_CHAR = ''' || v_escaped_value || '''';
            ELSIF  v_operator = 'LIKE[begin]' THEN
                v_SQLConstraint := v_SQLConstraint
                    || ' AND TVAL_CHAR LIKE ''' || v_escaped_value || '%'' ESCAPE ''\''';
            ELSIF  v_operator = 'LIKE[end]' THEN
                v_SQLConstraint := v_SQLConstraint
                    || ' AND TVAL_CHAR LIKE ''%' || v_escaped_value || ''' ESCAPE ''\''';
            ELSE   -- LIKE[contains] (default)
                v_SQLConstraint := v_SQLConstraint
                    || ' AND TVAL_CHAR LIKE ''%' || v_escaped_value || '%'' ESCAPE ''\''';
            END IF;

        -- FLAG
        ELSIF p_CONSTRAIN_BY_VALUE_TYPE = 'FLAG' THEN
            v_SQLConstraint := v_SQLConstraint
                || ' AND VALUEFLAG_CD = ''' || p_CONSTRAIN_BY_VALUE_CONSTRAINT || '''';

        -- LARGETEXT (Oracle Text)
        ELSIF p_CONSTRAIN_BY_VALUE_TYPE = 'LARGETEXT' THEN
            IF p_CONSTRAIN_BY_VALUE_OPERATOR = 'CONTAINS' THEN
                v_SQLConstraint := v_SQLConstraint
                    || ' AND CONTAINS(OBSERVATION_BLOB, ''' || p_CONSTRAIN_BY_VALUE_CONSTRAINT || ''') > 0';
            END IF;
        END IF; -- end by value type
    END IF; -- end concept_dimension check

    DBMS_OUTPUT.PUT_LINE('Generated constraint SQL: ' || v_SQLConstraint);
    RETURN v_SQLConstraint;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in udf_constraint_sql: ' || SQLERRM);
        RETURN '';
END;