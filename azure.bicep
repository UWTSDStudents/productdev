targetScope = 'resourceGroup'

// Weirdly, we have to create resources in 'westeurope' but since they are
// created in the resource group they end up in 'ukwest' anyway.
param resourceLocation string = 'westeurope' 

// There is no nice way to perform an application registration
// i.e. create an application registration object
// See https://stackoverflow.com/questions/69120936/how-do-i-use-bicep-or-arm-to-create-an-ad-app-registration-and-roles
@description('Service Principal ID used to authorize GitHub access to the web app')
@secure()
param principalId string // Service Principal ID

@description('GitHub repository URL for the SWA')
param swaGithubUrl string

@description('GitHub repository personal access token')
param swaGithubToken string

@description('Static web app name')
param swaName string = 'swa-${toLower(uniqueString(newGuid()))}' // Generate unique name

@description('GitHub repository URL for the Web App')
param webappGithubUrl string

@description('Web app name')
param webappName string = 'webapp-${toLower(uniqueString(newGuid()))}' // Generate unique name

@description('App service plan name')
param appServicePlanName string = 'appplan-${toLower(uniqueString(newGuid()))}' // Generate unique name


// Create the static web app
module swa 'bicep_modules/static-web-app.bicep' = {
  name: '${swaName}-module'
  params: {
     name: swaName
     location: resourceLocation
     githubUrl: swaGithubUrl
     githubToken: swaGithubToken
     appLocation: '/html'
  }
}

// Create the node.js web app
module app 'bicep_modules/web-app-github-linux.bicep' = {
  name: '${webappName}-module'
  params: {
     principalId: principalId
     name: webappName
     location: resourceLocation
     newOrExistingAppServicePlan: 'new'
     appServicePlanName: appServicePlanName
     runtime: 'node|18-lts'
     githubUrl: webappGithubUrl
     branch: 'main'
     appCommandLine: 'npm run start'
  }
}
