# Product App and API development environment
Run "npm install" in both the webapp and webapi directories.
In the webapp directory, a subdirectory dist contains a file called bundle.js.
If you make changes to the webapp code, these files must be built into this file using webpack.
To run webpack, use either the command:
1. npm run watch
2. npm run build
The first command can be used during development and runs in the background rebuilding the bundle as you make changes. However,
the browser may cache the bundle.js file so you may not see the changes as expected.
The second command is used for the final production version of the webapp and should be used before deploying the app to the cloud.

The webapp, api, database and bash (az-sqlcmd) containers are all started usint docker-compose up.
The database takes sometime to start, therefore the az-sqlcmd container has to wait sometime before it can execute commands.
For the first execution of docker-compose up, you have to wait for the execution of the commands that create the initial user, database
and Product table.

Note: the webapp and webapi are committed separately to GitHub and pulled here as submodules.
For a description of submodules, see https://git-scm.com/book/en/v2/Git-Tools-Submodules
