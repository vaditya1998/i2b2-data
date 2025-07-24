CREATE FUNCTION [dbo].[udf_constraint_ontology_sql] (
	@C_OPERATOR VARCHAR(30),
	@C_COLUMNNAME VARCHAR(30),
	@C_COLUMNDATATYPE VARCHAR(50),
	@C_DIMCODE VARCHAR(1000)
)
RETURNS NVARCHAR(4000)
BEGIN

	DECLARE @SQLConstraint NVARCHAR(4000) = ''

	IF @C_OPERATOR = 'LIKE'
		SELECT @SQLConstraint += @C_COLUMNNAME+' ' +@C_OPERATOR + ' ''' +REPLACE(@C_DIMCODE,'''','''''')+ '%'''

	IF @C_OPERATOR IN ( '>', '>=', '=', '<>', '<', '<=',  'BETWEEN')
		BEGIN
			IF @C_COLUMNDATATYPE = 'N'
				BEGIN
					SELECT @SQLConstraint = @C_COLUMNNAME + ' ' + @C_OPERATOR + ' ' + @C_DIMCODE
				END
			ELSE
				BEGIN
					SELECT @SQLConstraint = @C_COLUMNNAME + ' ' + @C_OPERATOR + ' ''' + @C_DIMCODE + ''''
				END
		END

	IF @C_OPERATOR IN ('IN')
		SELECT @SQLConstraint =  @C_COLUMNNAME + ' ' + @C_OPERATOR + ' ('  +@C_DIMCODE+ ')'

	RETURN @SQLConstraint

END


