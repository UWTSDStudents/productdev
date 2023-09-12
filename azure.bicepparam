// NOTE: when using JSON you can use inline parameters and a local parameters file in the same deployment operation. 
// For example, you can specify some values in the local parameters file and add other values inline 
// during deployment e.g.
// az deployment sub create --name myAppBicepDeployment --location westeurope
// --subscription <SUBSCRIPTION_ID> \
// --template-file ./azure.bicep \
// --parameters ./azure.bicepparam  principalId=<PRINCIPAL_ID> swaGithubToken=<SWA_GITHUB_PA>
// If you provide values for a parameter in both the local parameters file and inline,
// the inline value takes precedence. 
// This has not been implemented for Bicep parameters file. 
// Therefore, instead of using inline parameters we have to substitute their values into this file
// before deployment.

using './azure.bicep'

param principalId = '<PRINCIPAL_ID>' // Set in GitHub workflow file

param swaGithubUrl = 'https://github.com/UWTSDStudents/productwebapp'
param swaGithubToken = '<SWA_PA_TOKEN>'  // Set in GitHub workflow file using a GitHub secret
param webappGithubUrl = 'https://github.com/UWTSDStudents/productwebapi'
param swaName = 'mySwa'

// The web app name needs to produce a unique FQDN
// your-app-name.azurewebsites.net
// In Bash, something like this webAppName="mywebapp$RANDOM" 
// IMPORTANT: Remember to change the name in the webpack.prod.js file.
param webappName = 'myWebApp16964'

param appServicePlanName  = 'myAppServicePlan'


/*
JSON equivalent of the above Bicep file (e.g. azureparam.json)
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "principalId": {
            "value": "" 
        },
        "rgLocation": {
            "value": "ukwest" 
        },
        "rgName": {
            "value": "myWebAppResourceGroup" 
        },
        "swaGithubUrl": {
            "value": "https://github.com/UWTSDStudents/productwebapp"
        },
        "swaGithubToken": {
            "value": ""
        },
        "webappGithubUrl": {
            "value": "https://github.com/UWTSDStudents/productwebapi"
        },
        "swaName": {
            "value": "mySwa"
        },
        "webappName": {
            "value": "myWebApp16964"
        },
        "appServicePlanName": {
            "value": "myAppServicePlan"
        }
    }
}
*/
