#### DOCKERFILE FOR SQL COMMAND CONSOLE ##############
# You can connect to this container like this:
# docker exec -it az-sqlcmd bash
# and execute commands like this
# sqlcmd -S mssql -U docker -P Password@123 -Q "USE mydb"

FROM mcr.microsoft.com/mssql-tools
COPY wait_for_it.sh /usr/src/app/wait_for_it.sh
COPY cleanup.sh /usr/src/app/cleanup.sh
RUN apt-get update && apt-get install -y gettext-base

# Change to the working directory
WORKDIR /usr/src/app




