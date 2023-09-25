// The default subscription where the resources will be created
targetScope = 'subscription'

//*******************************************************************************
// Create the resources that you do not want to create in GitHub Actions 
// because you do not want to provide permissions to GitHub Actions
//*******************************************************************************

@description('Resources are deployed to this resource group')
param rgName string = 'rg-${deployment().name}'

@description('Location for the deployed resources')
param rgLocation string = 'ukwest'

@description('The subscripotion ID where the resources will be created')
@secure()
param subscriptionId string // Subscription ID

@description('Service Principal ID used for GitHub to log into Azure')
@secure()
param principalId string // Service Principal ID

// @description('GitHub token')
// @secure()
// param githubToken string // GitHub token

// Create the resource group
// Creating it in the setup 
// Note: if the resource group already exists, this will do nothing
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: rgLocation
}

// Assign Owner role to the Application Registration service principal that
// GitHub Actions can manage and deploy to the resource group
module spRole 'bicep_modules/resource-group-role-assign.bicep' = {
  name: 'role-${rg.name}-module'
  scope: rg
  params: {
    subscriptionId: subscriptionId
    principalId: principalId
    roleType: 'Owner'
  }
}

// Set the GitHub personal access token
// If you fail to add the GitHub token you may get an error
// "Cannot find SourceControlToken with name GitHub"
// when using Service Principal to setup continuous deployment e.g.
// a webapp (service)
// https://github-wiki-see.page/m/veleek/kudu/wiki/Investigating-continuous-deployment
// https://github.com/projectkudu/ARMClient/wiki/Update-SourceControlTokens
// Note: you need tenant level permissions to store the token
// module token './bicep_modules/github-token.bicep' = {
//   name: 'token-module'
//   scope: tenant()
//   params: {
//     token: githubToken
//   }
// }
