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
param swaBranch string = 'main'

@description('GitHub repository personal access token')
param swaGithubToken string

@description('Static web app name')
param swaName string = 'swa-${toLower(uniqueString(newGuid()))}' // Generate unique name

@description('GitHub repository URL for the Web App')
param webAppGithubUrl string
param webAppBranch string = 'main'
param webAppRuntime string = 'node|18-lts'

@description('Web app name')
param webAppName string = 'webapp-${toLower(uniqueString(newGuid()))}' // Generate unique name

@description('App service plan name')
param appServicePlanName string = 'appplan-${toLower(uniqueString(newGuid()))}' // Generate unique name


// Create the static web app
module swa 'bicep_modules/static-web-app.bicep' = {
  name: '${swaName}-module'
  params: {
     name: swaName
     location: resourceLocation
     githubUrl: swaGithubUrl
     branch: swaBranch
     githubToken: swaGithubToken
     appLocation: '/'
     outputLocation: '/'
  }
}

// Create the node.js web app
module app 'bicep_modules/web-app-github-linux.bicep' = {
  name: '${webAppName}-module'
  params: {
     principalId: principalId
     name: webAppName
     location: resourceLocation
     newOrExistingAppServicePlan: 'new'
     appServicePlanName: appServicePlanName
     runtime: webAppRuntime
     appCommandLine: 'npm run start'
  }
}

// NOT REQUIRED
// In this case, I thought it was more transparent to use create the credentials
// outside of a Bicep file, such as in the GitHub workflow file, because the
// resultant site credentials are sensitive and also need to be stored.
// However, it is possible to create the credentials in Bicep using the following
// resource runCodeDeploy 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: '${uniqueString(resourceGroup().id)}-runCodeDeploy-module'
//   location: resourceLocation
//   kind: 'AzureCLI'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     azCliVersion: '2.26.2'
//     scriptContent: '''
//       siteCreds=$(./web-app-code-deployment-setup.azcli $principalId ${subscription().id} $rgName $webappName "AZURE_WEBAPP_PUBLISH_PROFILE")
//       echo '{ "site_creds": ${siteCreds} }' > $AZ_SCRIPTS_OUTPUT_PATH
//     '''
//     arguments: '$principalId ${subscription().id} $rgName $webappName "AZURE_WEBAPP_PUBLISH_PROFILE"'
//     supportingScriptUris: [
//       'https://raw.githubusercontent.com/UWTSDSoACInfrastructure/BicepModules/main/cmd-scripts/web-app-code-deployment-setup.azcli', 'https://raw.githubusercontent.com/UWTSDSoACInfrastructure/BicepModules/main/cmd-scripts/web-app-site-creds.azcli'
//     ]
//     retentionInterval: 'P1D'
//     cleanupPreference: 'Always'
//     timeout: 'PT1H'
//     forceUpdateTag: 'v1'
//   }
// }

output resourceLocation string = resourceLocation
output swaName string = swaName
output webAppName string = webAppName

// We need to return these values to allow the GitHub action to
// to enable source code deployment and to apply the site credentials to the web app
output webAppGithubUrl string = webAppGithubUrl
output webAppBranch string = webAppBranch
output webAppRuntime string = webAppRuntime

// If we want to modify the web app settings later, then we should return
// the current settings
output webAppSettings object = app.outputs.appSettings

