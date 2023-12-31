# Product App and API development environment
Run "npm install" in both the webapp and webapi directories.
## Static Web App (SWA) "webapp"
In the webapp directory, a subdirectory dist contains a file called bundle.js.
If you make changes to the webapp code, these files must be built into this file using webpack.
To run webpack, use either the command:
1. npm run watch
2. npm run build
The first command can be used during development and runs in the background rebuilding the bundle as you make changes. However, the browser may cache the bundle.js file so you may not see the changes as expected.
The second command is used for the final production version of the webapp and should be used before deploying the app to the cloud.
### Route configuration
You need to specify the valid URLs for the static web app.
When running on Docker on your own PC, this web app is simulated within an nginix server. The configuration of the routes are defined in the nginx.conf file. However, the same routes also need to be added to the staticwebapp.config.json file for deployment into the Azure SWA.

## Testing on your PC using Docker
The webapp, api, database and bash (az-sqlcmd) containers are all started usint docker-compose up.
The database takes sometime to start, therefore the az-sqlcmd container has to wait sometime before it can execute commands.
For the first execution of docker-compose up, you have to wait for the execution of the commands that create the initial user, database
and Product table.

## GitHub submodules
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
When making changes to a submodule do the following:
```
cd webapp
git add .
git commit -m"My changes"
git push origin main
# Update the submodule in the parent repo
cd ..
git add webapp
git commit -m"Updated webapp submodule"
git push

NOTE:
Sometimes the HEAD and the origin/main get out of sync on a submodule and the files do not get
correctly pushed to the submodule repo.
To fix this, push like this and check the log:
cd webapp
git push origin main
git log
```
# Azure Deployment
## Initial (one-off) setup required before deployment
To deploy to azure, you must first execute the setup.azcli (bash) file passing it the subscription ID, resource group name where the resource will be deployed and a globally unique display application name.
```
./setup.azcli <SUBSCRIPTION ID> <RG NAME> <APP NAME>
./setup.azcli bd3.....17 mikes-deployment-rg myAppObj
```
This creates (or at least checks for the existance of) the Application object (App Registration) and the associated service principal. It also executes the setup.bicep file to create the required resources, in this case just the resource group we require.
Note: You cannot currently do an Application Registration in Bicep. Hence, this initial setup. Also, creating the resource group just makes more sense here since you only do this once.
## GitHub Workflows
The GitHub workflow files (files are run in parallel), and are found in the directory .github/workflows.
Note: there are similar workflow directories in the webapp and webapi directories but these are created automatically. For the SWA "webapp" Azure builds if for us, while for the Web App "webapi" we use the create-web-app-nodejs-worflow.azcli script to build the cd.yaml workflow file. Both these files are pushed to their respecitive repos.
### cd.yaml Web App Code Deployment workflow
This file should look something like this:
```
# Docs for the Azure Web Apps Deploy action: https://github.com/Azure/webapps-deploy
# More GitHub Actions for Azure: https://github.com/Azure/actions

name: Build and deploy Node.js app to Azure Web App - mikesTest

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Node.js version
        uses: actions/setup-node@v1
        with:
          node-version: '18.x'

      - name: npm install, build, and test
        run: |
          npm install
          npm run build --if-present
          npm run test --if-present

      - name: Upload artifact for deployment job
        uses: actions/upload-artifact@v2
        with:
          name: node-app
          path: .

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
      - name: Download artifact from build job
        uses: actions/download-artifact@v2
        with:
          name: node-app

      - name: 'Deploy to Azure Web App'
        id: deploy-to-webapp
        uses: azure/webapps-deploy@v2
        with:
          app-name: 'mikesTest'
          slot-name: 'production'
          publish-profile: ${{ secrets.AzureAppService_PublishProfile_1234 }}
          package: .
```
### GitHub Jobs
GitHub jobs are run in parallel, we have just one job we have named "build-and-deploy".
### GitHub Steps
Each job contains a number of steps (actions) each of which is executed in sequence.
## ci.yaml
This workflow file executes if the main branch changes on the productdev repo
It contains 1 job that performs a number of steps
1. Checks out the head of the productdev repo (the repo containing the ci.yaml file)
2. Logs into Azure using the registed app and federated credentials (the most secure approach).
3. Updates the azure.bicepparam file so that it has the correct AZURE_SERVICE_PRINCIPAL_ID and GITHUB_PERSONAL_TOKEN values
4. Deploys the azure.bicep file using this the azure.bicepparam file
5. Creates the site credentials
5. Stores the site credentials in a GitHub secret
6. Enables code deployment (which needs these site credentials)
7. Logs out of Azure (not sure this is strictly needed)
## Deployment Setup
The Azure parameters required for deployment are provided in the azure.bicepparam file.
Do not change the values in triangle brackets e.g. <PRINCIPAL_ID>, since these are automatically provided during deployment.
## SWA configuration
You need to provide the URL of the webservice in the webpack.prod.js file in the REACT_APP_PRODUCTS_API_URL value.