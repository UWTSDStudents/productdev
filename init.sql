-- Try tsql linter: install npm install tsqllint -g

-- Do not display the row count messages to reduce the output noise
-- when executing multiple queries
SET NOCOUNT ON;

-- Check if the database exists
IF DB_ID('$MSSQL_DATABASE') IS NOT NULL
BEGIN
    -- Database exists
    PRINT 'Database exists';

    -- Check if the user already exists
    IF DB_ID('$MSSQL_DATABASE') IS NOT NULL AND EXISTS (SELECT * FROM $MSSQL_DATABASE.sys.sysusers WHERE name = '$MSSQL_USER_NAME')
    BEGIN
        -- User already exists
        PRINT 'User already exists';
    END
    ELSE
    BEGIN
        -- USE master; Not required to coonnect since we start connected to master database
        -- Create a new user
        CREATE LOGIN $MSSQL_USER_NAME WITH PASSWORD = '$MSSQL_USER_PASSWORD';
        -- Allow user to connect to the server
        GRANT CONNECT SQL TO $MSSQL_USER_NAME;

        -- Make them a user and owner of the database
        USE $MSSQL_DATABASE;
        CREATE USER $MSSQL_USER_NAME FOR LOGIN $MSSQL_USER_NAME;
        EXEC sp_addrolemember 'db_owner', $MSSQL_USER_NAME;

        -- User created successfully
        PRINT 'User created successfully';
    END;


    IF DB_ID('$MSSQL_DATABASE') IS NOT NULL AND OBJECT_ID('$MSSQL_DATABASE.dbo.Product', 'U') IS NULL
    BEGIN
        -- Use the database
        USE $MSSQL_DATABASE;

        -- Create the Product table
        CREATE TABLE Product (Id INT IDENTITY(1,1) PRIMARY KEY, Name VARCHAR(50), Price DECIMAL(10, 2), Description VARCHAR(500));
    END
    ELSE
    BEGIN
        PRINT 'Product table already exists';
    END
END
ELSE
BEGIN
    -- Database does not exist
    -- There is something broken that prevents us creating the database here and now
    -- hence we end up creating prior to executing this file.
    PRINT 'Database does not exist';
END;

-- Revert to default behavior and display row count messages
SET NOCOUNT OFF;
