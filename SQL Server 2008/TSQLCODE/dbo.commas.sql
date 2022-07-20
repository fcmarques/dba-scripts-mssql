

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[commas](@input_number SQL_VARIANT) RETURNS VARCHAR(80) 
AS

BEGIN

    DECLARE @input_string VARCHAR(80) = CAST(@input_number as VARCHAR);
    DECLARE @output_string VARCHAR(80) = '';

    IF (isNumeric(@input_string) != 1)
    BEGIN
        RETURN(@input_string);
    END;

    DECLARE @sign_part VARCHAR(80) = '';
    DECLARE @precision_part VARCHAR(80) = '';

    IF (LEFT(@input_string, 1) = '-' or LEFT(@input_string, 1) = '+')
    BEGIN
        SET @sign_part = LEFT(@input_string, 1);
        SET @input_string = SUBSTRING(@input_string, 2, LEN(@input_string));
    END;

    DECLARE @dot_pos int = CHARINDEX('.', @input_string);
    DECLARE @scale_part VARCHAR(80) = @input_string;

    IF (@dot_pos > 0)
    BEGIN
        SET @scale_part = SUBSTRING(@input_string, 1, @dot_pos-1);
        SET @precision_part = SUBSTRING(@input_string, @dot_pos+1, LEN(@input_string));
    END;

    WHILE (LEN(@scale_part) > 3)
    BEGIN
        SET @output_string = ',' + RIGHT(@scale_part, 3) + @output_string;
        SET @scale_part = SUBSTRING(@scale_part, 1, LEN(@scale_part)-3);
    END;
      
    IF LEN(@scale_part) > 0 
    BEGIN
        SET @output_string = @scale_part + @output_string;
    END;

    IF LEN(@precision_part) > 0 
    BEGIN
        SET @output_string = (@output_string + '.' + @precision_part);
    END;

    RETURN(@sign_part + @output_string);

END;

GO

