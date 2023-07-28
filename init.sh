#!/bin/bash

echo "Waiting 30s for database to start"
sleep 30s

# Wait for the SQL Server service to start
MAX_RETRIES=40
RETRY_INTERVAL=5
retries=0

while true; do
    if [ $retries -eq $MAX_RETRIES ]; then
        echo "Max retries reached. Unable to connect to the SQL Server."
        exit 1
    fi

    # /opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -Q "SELECT 1" >/dev/null 2>&1
    DBSTATUS=$(/opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")

    if [[ $? -eq 0 ]] && [[ $DBSTATUS -eq 0 ]]; then
        break
    fi

    echo "SQL Server is not yet available. Retrying in $RETRY_INTERVAL seconds..."
    retries=$((retries+1))
    sleep $RETRY_INTERVAL
done

# Substitute environment variables in the SQL script
envsubst < /usr/src/app/init.sql > /usr/src/app/expanded_init.sql
# cat /usr/src/app/expanded_init.sql

# Execute the SQL script
echo "Login as SA then setup the database"
/opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -d master -Q "IF DB_ID('$MSSQL_DATABASE') IS NULL CREATE DATABASE $MSSQL_DATABASE"
/opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -d master -i /usr/src/app/expanded_init.sql

/bin/bash
