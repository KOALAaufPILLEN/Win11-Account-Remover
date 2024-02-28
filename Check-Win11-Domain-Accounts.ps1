# Retrieve the list of domain accounts
$domainAccounts = Get-WmiObject -Class Win32_UserAccount -Filter "Domain like '%%'"

# Display the domain account information
$index = 1
$accountChoices = @{}
foreach ($account in $domainAccounts) {
    # Exclude Administrator, DefaultAccount, and WDAGUtilityAccount
    if ($account.Name -notin "Administrator", "DefaultAccount", "WDAGUtilityAccount") {
        $choice = "Account #$index - $($account.Name) in $($account.Domain)"
        $accountChoices.Add($index, $account)
        Write-Host $choice
        $index++
    }
}

# Prompt for the account to remove
$selectedAccount = Read-Host "Enter the number of the account you want to remove"

# Remove the selected account
if ($accountChoices.ContainsKey($selectedAccount)) {
    $accountToRemove = $accountChoices[$selectedAccount]
    $option = Read-Host "Do you want to remove associated data as well? (Y/N)"
    if ($option -eq "Y" -or $option -eq "y") {
        $accountToRemove.Delete($true)  # Remove account and associated data
    } else {
        $accountToRemove.Delete($false)  # Remove account only
    }
    Write-Host "Account $($accountToRemove.Name) in $($accountToRemove.Domain) has been removed."
} else {
    Write-Host "Invalid selection. No account has been removed."
}

# Define the path to the user folders
$userFoldersPath = "C:\Users"

# Exclude folder names
$excludedFolders = @("Default", "Puplic")

# Perform the checkup
$emptyFolders = Get-ChildItem -Path $userFoldersPath -Directory |
    Where-Object { $_.Name -notin $excludedFolders -and (Get-ChildItem -Path $_.FullName -Recurse | Measure-Object).Count -eq 0 }

# Display the results
if ($emptyFolders.Count -eq 0) {
    Write-Host "All user folders are empty (excluding 'Default' folder)."
} else {
    Write-Host "The following user folders contain data:"
    foreach ($folder in $emptyFolders) {
        Write-Host "- $($folder.Name)"
    }
    
    # Prompt for removal of specific folders
    $removeFoldersOption = Read-Host "Do you want to remove any of these folders? (Y/N)"
    if ($removeFoldersOption -eq "Y" -or $removeFoldersOption -eq "y") {
        $foldersToRemove = Read-Host "Enter the names of the folders you want to remove (comma-separated)"
        $foldersToRemove = $foldersToRemove -split ","
        
        foreach ($folderName in $foldersToRemove) {
            $folderPath = Join-Path -Path $userFoldersPath -ChildPath $folderName
            if (Test-Path -Path $folderPath -PathType Container) {
                Remove-Item -Path $folderPath -Recurse -Force
                Write-Host "Folder '$folderName' has been removed."
            } else {
                Write-Host "Folder '$folderName' does not exist."
            }
        }
    }
}
