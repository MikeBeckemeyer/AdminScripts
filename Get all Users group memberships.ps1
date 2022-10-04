#get all group memberships for enabled users in OU
#Prints data to console and exports a file.

$ReportPath = "c:\report.csv"
$TargetOU = "OU=Users,DC=DC,DC=local"


#Console print log
get-ADUser -Filter 'enabled -eq $true' -SearchBase $TargetOU -Properties * -pv Users | 
    Get-ADPrincipalGroupMembership -pv Group| Select-Object @{ n='User Name'; e={ $Users.name }}, @{ n='Group Name'; e={ $Group.name }} | Format-Table


#export file with data
get-ADUser -Filter 'enabled -eq $true' -SearchBase $TargetOU -Properties * -pv Users | 
    Get-ADPrincipalGroupMembership -pv Group| Select-Object @{ n='User Name'; e={ $Users.name }}, @{ n='Group Name'; e={ $Group.name }} |
     Export-Csv -Path $ReportPath



