#Import-Module AzureAd
#Import-Module -Name Az
#Connect-AzureAD
#Login-AzAccount

# User creation
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "QWE987qwe!@#"

For ($i=1; $i -le 20; $i++) {
    New-AzureADUser -AccountEnabled $true -DisplayName "Test User $($i)" -UserPrincipalName "TestUser$($i)@mssolinovoutlook.onmicrosoft.com" -MailNickName "TestUser$($i)" -PasswordProfile $PasswordProfile
    }

# Log init
$Log = @()

# Group creation
New-AzureADGroup -DisplayName "Varonis Assignment2 Group" -MailNickName "VaronisAssignment2Group" -SecurityEnabled $true -MailEnabled $false
$GroupId = (Get-AzureADGroup -SearchString "VaronisAssignment2Group").ObjectId

# Users creation with customized log
foreach ($User in Get-AzureADUser -SearchString "Test User"){
    $UserId = $User.ObjectId
    try {
        Add-AzureADGroupMember -ObjectId $GroupId -RefObjectId $UserId
    }
    catch {
        $AddUserError = $_.Exception.Message
    }
    if ($AddUserError -eq $null){
        $Result = "Success"
    }
    else {$Result = "Failure"}

    $Timestamp = Get-Date -Format o

    $LogEntry = New-Object PSObject
    $LogEntry | Add-Member -MemberType NoteProperty -Name "User Name" -Value $User.UserPrincipalName
    $LogEntry | Add-Member -MemberType NoteProperty -Name "Timestamp" -Value $Timestamp
    $LogEntry | Add-Member -MemberType NoteProperty -Name "Attemp result" -Value $Result
    
    $Result = $null

    $Log += $LogEntry
    }

# Customized log export
$Log | Export-Csv -Path "C:\Assinment2Log.csv" -NoTypeInformation


# Blob creation & log upload
$location = "westeurope"
$AzResourceGroup = "Assignment2RG"
New-AzResourceGroup -Name $AzResourceGroup -Location $location
$StorageAccount = New-AzStorageAccount -ResourceGroupName $AzResourceGroup -Name "sovarassignment2storage" -SkuName Standard_LRS -Location $location
$context = $StorageAccount.Context
$containerName = "sovarassignment2blob"
New-AzStorageContainer -Name $containerName -Context $context -Permission blob