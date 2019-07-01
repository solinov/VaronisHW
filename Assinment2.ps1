#AzureAD connection
Import-Module AzureAd
Connect-AzureAD

# User creation
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "QWE987qwe!@#"

For ($i=1; $i -le 20; $i++) {
    New-AzureADUser -AccountEnabled $true -DisplayName "Test User $($i)" -UserPrincipalName "TestUser$($i)@mssolinovoutlook.onmicrosoft.com" -MailNickName "TestUser$($i)" -PasswordProfile $PasswordProfile
    }

# Log init
#$Log = $null

New-AzureADGroup -DisplayName "Varonis Assignment2 Group" -MailNickName "VaronisAssignment2Group" -SecurityEnabled $true -MailEnabled $false
$GroupId = (Get-AzureADGroup -SearchString "VaronisAssignment2Group").ObjectId

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
