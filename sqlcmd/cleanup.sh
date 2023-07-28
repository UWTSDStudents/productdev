#!/bin/bash

# Drop the user from the database.
# However, dropping the database automatically drops all users associated with it.
# /opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -d master -Q "USE $MSSQL_DATABASE"
# /opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -d master -Q "DROP USER $MSSQL_USER_NAME"

# Drop the database and all its contents including any associated users.
/opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -d master -Q "DROP DATABASE $MSSQL_DATABASE"

# Drop the user at the system-level
/opt/mssql-tools/bin/sqlcmd -S $MSSQL_SERVER -U SA -P $MSSQL_SA_PASSWORD -d master -Q "DROP LOGIN $MSSQL_USER_NAME"
