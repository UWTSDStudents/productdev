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

Note: the webapp, webapi and bicep_modules are committed separately to GitHub and pulled here as submodules.
Each submodule is created as a separate branch on their respective repositories.
For a description of submodules, see https://git-scm.com/book/en/v2/Git-Tools-Submodules
Created like this:
$ git submodule add -b <branch> <remote_url> <destination_folder>
e.g. git submodule add -b main https://github.com/UWTSDStudents/productwebapp webapp

You can remove a submodule like this:
```
# Remove the submodule entry from .git/config
git submodule deinit -f webapp

# Remove the submodule directory from the superproject's .git/modules directory
rm -rf .git/modules/webapp

# Remove the entry in .gitmodules and remove the submodule directory located at path/to/submodule
git rm -f webapp
```
## Initial (one-off) setup required before deployment
To deploy to azure, you must first execute the setup.azcli (bash) file passing it the subscription ID, resource group name where the resource will be deployed and a globally unique display application name.
```
./setup.azcli <SUBSCRIPTION ID> <RG NAME> <APP NAME>
```
This creates (or at least check for the existance of) the Application object (App Registration) and the associated service principal. It also executes the setup.bicep file to create the required resources, in this case just the resource group we require.
Note: You cannot currently do an Application Registration in Bicep. Hence, this initial setup. Also, creating the resource group.
## GitHub Workflows
The GitHub workflow files (files are run in parallel), and are found in the directory .github/workflows.
Note: there are similar workflow directories in the webapp and webapi directories but these are created automatically (we build the webapi workflow file ourselves in code-continuous-deployment.yaml).
## GitHub Jobs
GitHub jobs are run in parallel, we have just one job we have named "build-and-deploy".
## GitHub Steps
Each job contains a number of steps (actions) each of which is executed in sequence.
# ci.yaml
This workflow file executes if the main branch changes on the productdev repo
It contains 1 job and a number of steps
1. Checkout the head of the productdev repo (the repo containing the ci.yaml file)
2. Log into Azure using the registed app and federated credentials (the most secure approach).
3. Update the azure.bicepparam file so that it has the correct AZURE_SERVICE_PRINCIPAL_ID and SWA_GITHUB_PERSONAL_TOKEN values
4. Deploy the azure.bicep file with the azure.bicepparam file
5. Logout of Azure (not sure this is strictly needed)
