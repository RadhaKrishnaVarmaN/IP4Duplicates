USE [master];
Go

IF DB_ID('Ip4Duplicate') IS NULL
BEGIN
	CREATE DATABASE [Ip4Duplicate];
END
GO

USE Ip4Duplicate;
Go

IF OBJECT_ID('ip4') IS NOT NULL
BEGIN
	DROP TABLE dbo.ip4
END
GO

CREATE TABLE dbo.ip4
(
	id INT IDENTITY(1,1) PRIMARY KEY,
    
	account VARCHAR(50),
	ip_value VARCHAR(50),
    
	is_valid BIT,
	is_range BIT,
	o1_lb INT,
	o1_ub INT,
	o2_lb INT,
	o2_ub INT,
	o3_lb INT,
	o3_ub INT,
	o4_lb INT,
	o4_ub INT,
	comment VARCHAR(100)
)
GO

IF OBJECT_ID('fn_ip4') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.fn_ip4
END
GO

CREATE FUNCTION dbo.fn_ip4
(
	@ip_value VARCHAR(50)
)
RETURNS @ipdata TABLE (
	is_valid BIT,
	is_range BIT,
	o1_lb	INT,
	o1_ub	INT,
	o2_lb	INT,
	o2_ub	INT,
	o3_lb	INT,
	o3_ub	INT,
	o4_lb	INT,
	o4_ub	INT,
	comment	VARCHAR(50))
AS
BEGIN
	DECLARE   @o1_lb AS INT
			, @o1_ub AS INT
			, @o2_lb AS INT
			, @o2_ub AS INT
			, @o3_lb AS INT
			, @o3_ub AS INT
			, @o4_lb AS INT
			, @o4_ub AS INT

	DECLARE   @p1 AS VARCHAR(10)
			, @p2 AS VARCHAR(10)
			, @p3 AS VARCHAR(10)
			, @p4 AS VARCHAR(10)

	SELECT	  @ip_value = LTRIM(RTRIM(ISNULL(@ip_value, '')))
			, @p1 = PARSENAME(@ip_value,4)
			, @p2 = PARSENAME(@ip_value,3)
			, @p3 = PARSENAME(@ip_value,2)
			, @p4 = PARSENAME(@ip_value,1)

	IF @p1 = '' OR @p2 = '' OR @p3 = '' OR @p4 = ''
	BEGIN
		INSERT INTO @ipdata(is_valid, comment)
		SELECT	0, 'Invalid value. ErrCode=1'
		RETURN;
	END

	SELECT 	  @p1 = CASE WHEN @p1 = '*' THEN '0-255' ELSE @p1 END
			, @p2 = CASE WHEN @p2 = '*' THEN '0-255' ELSE @p2 END
			, @p3 = CASE WHEN @p3 = '*' THEN '0-255' ELSE @p3 END
			, @p4 = CASE WHEN @p4 = '*' THEN '0-255' ELSE @p4 END

	IF @p1 LIKE '%*%' OR @p2 LIKE '%*%' OR @p3 LIKE '%*%' OR @p4 LIKE '%*%'
	BEGIN
		INSERT INTO @ipdata(is_valid, comment)
		SELECT	0, 'Invalid value. ErrCode=2'
		RETURN;
	END

	SELECT	  @p1 = REPLACE(@p1, '-', '.')
			, @p2 = REPLACE(@p2, '-', '.')
			, @p3 = REPLACE(@p3, '-', '.')
			, @p4 = REPLACE(@p4, '-', '.')

	IF @p1 NOT LIKE '%[0123456789.]%' OR @p2 NOT LIKE '%[0123456789.]%'
	OR @p3 NOT LIKE '%[0123456789.]%' OR @p4 NOT LIKE '%[0123456789.]%'
	BEGIN
		INSERT INTO @ipdata(is_valid, comment)
		SELECT	0, 'Invalid value. ErrCode=3'
		RETURN;
	END

	IF @p1 LIKE '%[0123456789]%.' OR @p2 LIKE '%[0123456789]%.' 
	OR @p3 LIKE '%[0123456789]%.' OR @p4 LIKE '%[0123456789]%.'
	BEGIN
		INSERT INTO @ipdata(is_valid, comment)
		SELECT	0, 'Invalid value. ErrCode=4'
		RETURN;
	END

	SELECT	  @o1_lb = CONVERT(INT, PARSENAME(@p1, 2))
			, @o1_ub = CONVERT(INT, PARSENAME(@p1, 1))
			, @o1_lb = CASE WHEN @o1_lb IS NULL THEN @o1_ub ELSE @o1_lb END

			, @o2_lb = CONVERT(INT, PARSENAME(@p2, 2))
			, @o2_ub = CONVERT(INT, PARSENAME(@p2, 1))
			, @o2_lb = CASE WHEN @o2_lb IS NULL THEN @o2_ub ELSE @o2_lb END
		
			, @o3_lb = CONVERT(INT, PARSENAME(@p3, 2))
			, @o3_ub = CONVERT(INT, PARSENAME(@p3, 1))
			, @o3_lb = CASE WHEN @o3_lb IS NULL THEN @o3_ub ELSE @o3_lb END
		
			, @o4_lb = CONVERT(INT, PARSENAME(@p4, 2))
			, @o4_ub = CONVERT(INT, PARSENAME(@p4, 1))
			, @o4_lb = CASE WHEN @o4_lb IS NULL THEN @o4_ub ELSE @o4_lb END

	IF (@o1_lb NOT BETWEEN 0 AND 255) OR (@o1_ub NOT BETWEEN 0 AND 255)
	OR (@o2_lb NOT BETWEEN 0 AND 255) OR (@o2_ub NOT BETWEEN 0 AND 255)
	OR (@o3_lb NOT BETWEEN 0 AND 255) OR (@o3_ub NOT BETWEEN 0 AND 255)
	OR (@o4_lb NOT BETWEEN 0 AND 255) OR (@o4_ub NOT BETWEEN 0 AND 255)
	BEGIN
		INSERT INTO @ipdata(is_valid, comment)
		SELECT	0, 'Invalid value. ErrCode=5'
		RETURN;
	END

	IF @o1_ub < @o1_lb OR @o2_ub < @o2_lb OR @o3_ub < @o3_lb OR @o4_ub < @o4_lb
	BEGIN
		INSERT INTO @ipdata(is_valid, comment)
		SELECT	0, 'Invalid value. ErrCode=6'
		RETURN;
	END

	INSERT INTO @ipdata
	SELECT   1 AS is_valid
			, CASE WHEN @o1_lb = @o1_ub AND @o2_lb = @o2_ub 
					AND @o3_lb = @o3_ub AND @o4_lb = @o4_ub 
				THEN 0 ELSE 1 END AS is_range
			, @o1_lb AS o1_lb
			, @o1_ub AS o1_ub
			, @o2_lb AS o2_lb
			, @o2_ub AS o2_ub
			, @o3_lb AS o3_lb
			, @o3_ub AS o3_ub
			, @o4_lb AS o4_lb
			, @o4_ub AS o5_ub
			, NULL AS comment
	RETURN;
END
GO
