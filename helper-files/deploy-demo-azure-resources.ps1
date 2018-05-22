$ErrorActionPreference = 'Stop'

$resourceNonce = [System.Guid]::NewGuid().ToString().Substring(0, 8)
$resourceGroupName = "AzSDK-Demo-RG-" + $resourceNonce
$deployLocation = "eastus"

Write-Host "Setting up demo resources. This will take about 3 to 4 minutes..." -ForegroundColor Yellow

$registeredProviders = Get-AzureRmResourceProvider

$storageProvider = $registeredProviders | Where-Object {$_.ProviderNamespace -eq "Microsoft.Storage"}
if (($storageProvider | Measure-Object).Count -le 0) {
    Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.Storage" | Out-Null
}

$webProvider = $registeredProviders | Where-Object {$_.ProviderNamespace -eq "Microsoft.Web"}
if (($webProvider | Measure-Object).Count -le 0) {
    Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.Web" | Out-Null
}

$securityProvider = $registeredProviders | Where-Object {$_.ProviderNamespace -eq "Microsoft.Security"}
if (($securityProvider | Measure-Object).Count -le 0) {
    Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.Security" | Out-Null
}

$accountId = (Get-AzureRmContext).Account.Id

$resourceGroup = Find-AzureRmResourceGroup -Tag @{"AccountId" = $accountId}
if ($resourceGroup -ne $null) {
    Write-Host "Found the demo ResourceGroup" -ForegroundColor Green
    #Set RGName, Nonce
    $resourceGroupName = $resourceGroup.name
    $resourceNonce = $resourceGroup.tags.Nonce
}
else {
    Write-Host "Creating a demo ResourceGroup" -ForegroundColor Yellow
    $resourceGroup = New-AzureRmResourceGroup -Name $resourceGroupName -Location $deployLocation `
        -Tag @{"AccountId" = $accountId; 
        "Nonce"            = $resourceNonce;
        "CreatedOn"        = [datetime]::UtcNow.ToString('yyyyMMddHHmmss')
    }
}

$webServicePlanName = "AzSDK-Demo-ASP-" + $resourceNonce
$webAppName = "azsdk-demo-wa-" + $resourceNonce
$storageAccountName = "azsdkdemosa" + $resourceNonce

try {
    $webServicePlan = Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName `
        -Name $webServicePlanName -ErrorAction Stop
    Write-Host "Found the demo AppServicePlan" -ForegroundColor Green
}
catch {
    $webServicePlan = New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName `
        -Name $webServicePlanName `
        -Location $deployLocation `
        -Tier Basic
    Write-Host "Creating a demo AppServicePlan" -ForegroundColor Yellow
}

$webapps = Get-AzureRmWebApp -ResourceGroupName $resourceGroupName
if ($webapps -eq $null -or $webapps.Count -eq 0) {
    $webApp = New-AzureRmWebApp -ResourceGroupName $resourceGroupName `
        -Name $webAppName `
        -AppServicePlan $webServicePlanName `
        -Location $deployLocation    
    Write-Host "Creating a demo AppService" -ForegroundColor Yellow
}
else {
    $webapps = Get-AzureRmWebApp -ResourceGroupName $resourceGroupName
    $webApp = $webapps | Select -First 1                   
    Write-Host "Found the demo AppService" -ForegroundColor Green
}
$webAppName = $webApp.SiteName

if ((Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName | Measure-Object).Count -eq 0) {
    $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName `
        -SkuName Standard_LRS `
        -Location $deployLocation `
        -Kind Storage
    Write-Host "Creating a demo StorageAccount" -ForegroundColor Yellow
}
else {
    $storageAccounts = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName
    $storageAccount = $storageAccounts | Select -First 1
    Write-Host "Found the demo StorageAccount" -ForegroundColor Green
}

$storageAccountName = $storageAccount.StorageAccountName

$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName

$storageAccountConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$($storageAccountKey[0].Value);EndpointSuffix=core.windows.net"

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName
Write-Host "Deploying the demo app" -ForegroundColor Yel
try {
    $container = Get-AzureStorageContainer -Context $storageAccount.Context `
        -Name "patent-images" -ErrorAction Stop      
}
catch {
    $container = New-AzureStorageContainer -Context $storageAccount.Context `
        -Name "patent-images" `
        -Permission Container
}

$wc = [System.Net.WebClient]::new()
$fileName = "prototype" + ".png";
$tempFilePath = Join-Path $env:TEMP $fileName
$wc.DownloadFile("https://raw.githubusercontent.com/azsdk/azsdk-demo-app/master/helper-files/prototype.png", $tempFilePath)
$na = Set-AzureStorageBlobContent -Context $storageAccount.Context `
    -Container $container.Name `
    -BlobType Block `
    -Blob $fileName `
    -File $tempFilePath `
    -Force

Remove-Item $tempFilePath -Force

$OptionalParameters = New-Object -TypeName Hashtable
$DeploymentName = $webAppName + "_" + $((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss-fff'))
$TemplateFile = "$PSScriptRoot\Internals\DeploymentTemplate.json"
$TemplateParametersFile = "$PSScriptRoot\Internals\DeploymentTemplate.param.json"
$OptionalParameters.Add("AppFarmName", $webServicePlanName)
$OptionalParameters.Add("AppName", $webAppName)
$OptionalParameters.Add("StorageAccountConnectionString", $storageAccountConnectionString.Trim())
Start-Sleep -Seconds 120
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -Name $DeploymentName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $TemplateParametersFile `
    @OptionalParameters `
    -Force | Out-Null

Write-Host "`nSetup completed`n" -ForegroundColor Green

Write-Host "Parameters:`n"
Write-Host "Resource Group : " -NoNewline
Write-Host "$resourceGroupName" -ForegroundColor Yellow
Write-Host "App Service Plan : " -NoNewline
Write-Host "$webServicePlanName" -ForegroundColor Yellow
Write-Host "Web App Name : " -NoNewline
Write-Host "$webAppName" -ForegroundColor Yellow
Write-Host "Storage Account Name : " -NoNewline
Write-Host "$storageAccountName" -ForegroundColor Yellow
$uri = "https://$($webApp.DefaultHostName)"
Write-Host "`nOpening the Demo App: " -NoNewline 
Write-Host "$uri`n" -ForegroundColor Yellow

cmd.exe /C start "$uri"
