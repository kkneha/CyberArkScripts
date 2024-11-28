[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$cred = Get-Credential

$login = @{
    'username' = $cred.GetNetworkCredential().Username
    'password' = $cred.GetNetworkCredential().Password
} | ConvertTo-Json

$auth = Invoke-RestMethod -Uri "<privilegeCloudUrl>/PasswordVault/API/auth/CyberArk/logon" -Method Post  -Body -$login -ContentType 'application/json'

$hdr =@{"Authorization" = $auth}

$path = $(Write-Host 'Input full path of csv without string including file name : ' -ForegroundColor Yellow -NonNewline; Read-Host)

$csv = Import-Csv $path

foreach($item in $csv){
    $safeURLid = $item.safeName

    $safeDetails =@{
        "safeName" = $item.safeName
        "description" = $item.description
        "managingCPM" = NULL
        "numberOfDaysRetention" = 7
        "autoPurgeEnabled" = "true"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "<privilegeCloudUrl>/PasswordVault/API/Safes" -Method Post  -Body -$safeDetails -ContentType 'application/json' -Headers $hdr

Start-Sleep -Seconds 3

$AdminUserDetails = {
    "memberName":"<memberid>",
    "searchIn": "<Vault or DC>",

    "permissions":
        {
        "useAccounts":true,
        "retrieveAccounts": true,
        "listAccounts": true,
        "addAccounts": true,
        "updateAccountContent": true,
        "updateAccountProperties": true,
        "initiateCPMAccountManagementOperations": true,
        "specifyNextAccountContent": true,
        "renameAccounts": true,
        "deleteAccounts": true,
        "unlockAccounts": true,
        "manageSafe": true,
        "manageSafeMembers": true,
        "backupSafe": true,
        "viewAuditLog": true,
        "viewSafeMembers": true,
        "accessWithoutConfirmation": true,
        "createFolders": true,
        "deleteFolders": true,
        "moveAccountsAndFolders": true,
        "requestsAuthorizationLevel1": true,
        "requestsAuthorizationLevel2": true
        },

        "MemberType": "User"
} | ConvertTo-Json

$uri = "<privilegeCloudUrl>/PasswordVault/API/Safes"+$safeURLid+"/Members/"

Invoke-RestMethod -Uri $uri -Method Post  -Body -$AdminUserDetails -ContentType 'application/json' -Headers $hdr