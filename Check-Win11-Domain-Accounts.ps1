# Retrieve the list of domain accounts
$domainAccounts = Get-WmiObject -Class Win32_UserAccount -Filter "Domain like '%%'"

# Display the domain account information
$index = 1
$accountChoices = @{}
foreach ($account in $domainAccounts) {
    $choice = "Account #$index - $($account.Name) in $($account.Domain)"
    $accountChoices.Add($index, $account)
    Write-Host $choice
    $index++
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