#Automatically add users from one AD group to a mailbox with 'Full Access' rights.  Allows mailboxes to be mapped automatically in Outlook Client, currently outlook will not auto-map a shared mailbox if permissions are assigned through a mailbox. 
#configure to work in a scheduled task to automate the process.  

$TargetGroupName = "GROUPNAME"
$TargetMailbox = "MAILBOXNAME"


#get members of Group
$GroupMembers = Get-DistributionGroupMember -Identity $TargetGroupName | Select-Object PrimarySmtpAddress

#get target mailbox members
$MailBoxUsers =  Get-MailboxPermission -Identity $TargetMailbox | Select-Object User #where{$_.User -ne "NT AUTHORITY\SELF"} 


foreach($GroupMembers in $GroupMembers)
{

    if($MailBoxUsers.User -eq $GroupMembers.PrimarySmtpAddress) {
        Write-Host $GroupMembers.PrimarySmtpAddress " Is already in " $TargetMailbox
    }
    else{
    Write-Host $GroupMembers.PrimarySmtpAddress " Adding to " $TargetMailbox
    Add-MailboxPermission -Identity $TargetMailbox -User $GroupMembers.PrimarySmtpAddress -AccessRights FullAccess
    }
}


