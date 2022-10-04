#Move user to Terminated user OU, disable account, set up email forwarding in exchange, remove all group memberships


#SET USER NAME FOR TERMED USER
$Username = "USERNAME"
# SET FORWARDING EMAIL ADDRESS FOR MANAGER.  If no forwarding is required remove email address i.e. $ForwardingEmail = ""
$ForwardingEmail = "ForwardingEmail@autopay.com"

$ExchangeDomain = "example.onmicrosoft.com"
$LogFilePath = "c:\test"

$TerminatedOU = "OU=EmployeesTerminated,OU=Users,DC=DCName,DC=local"
$adServer = "SERVERNAME"

#import the Active Directory module if not already up and loaded
$module = Get-Module | Where-Object {$_.Name -eq 'ActiveDirectory'}
if ($module -eq $null) {
		Write-Host "Loading Active Directory PowerShell Module"
		Import-Module ActiveDirectory -ErrorAction SilentlyContinue
	}
#import Exchange module for email forwarding
Import-Module ExchangeOnlineManagement

#disable user
Disable-ADAccount -Identity $Username

#move to term employee OU
Get-ADUser $Username | Move-ADObject -TargetPath $TerminatedOU

#Try to remove all group memberships
try{
	Get-ADUser -Identity $Username -Server $adServer
	#if that doesn't throw you to the catch this person exists. So you can continue

	$ADgroups = Get-ADPrincipalGroupMembership -Identity $Username | where {$_.Name -ne "Domain Users"}
	if ($ADgroups -ne $null){
		Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $ADgroups -Server $adServer -Confirm:$false
	}
}#end try
catch{
	Write-Host "$Username is not in AD"
}

#Email forwarding, if we do not have a forwarding email address.
if($forwardingEmail -ne $null){
Connect-ExchangeOnline -DelegatedOrganization $ExchangeDomain

Set-Mailbox -Identity $Username"@email.com" -ForwardingSmtpAddress $ForwardingEmail -DeliverToMailboxAndForward $true
}


#Logging
$Username | Out-File -FilePath $LogFilePath -Append
$ADgroups | Out-File -FilePath $LogFilePath -Append


