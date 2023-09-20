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
