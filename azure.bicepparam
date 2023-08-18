using './azure.bicep'

param principalId = '' // Set in GitHub workflow file

param rgLocation = 'ukwest'
param rgName = 'myWebAppResourceGroup'

param swaGithubUrl = 'https://github.com/UWTSDStudents/productwebapp'
param swaGithubToken = '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'
param webappGithubUrl = 'https://github.com/UWTSDStudents/productwebapi'
param swaName = 'mySwa'
param webappName = 'myWebApp'
param appServicePlanName  = 'myAppServicePlan'
