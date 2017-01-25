# validate user
import-module "C:\Program Files\PoSHServer\webroot\http\pwdtool\pwdtool-utils.psm1"
$username = $PoSHUsername.split('\\')[1]
$r = validateUser -username $username -group "All Permanent Staff"
if (! $r.valid) {
  @{"users" = @()} | ConvertTo-Json
  return
}

# is disabled https://msdn.microsoft.com/en-us/library/ms680832(v=vs.85).aspx 
<#
function isEnabled($userAccountControl) {
  if (($userAccountControl -band 0x0002) -eq 0) {
    return "1"; 
  } else {
    return "0";
  }
}
#>
# @{"Label"="enabled";e={(isEnabled -userAccountControl $_.useraccountcontrol)}}, `

$name = $PoSHPost.name

Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : looking for $name now")

try {
  Import-Module ActiveDirectory
  $users = Get-ADUser -ResultSetSize 20 -Filter 'Name -like $name' -Properties * | `
    where {$_.extensionAttribute14 -ne $null -and $_.extensionAttribute14.startsWith("/Students")} | `
    select-object Enabled, `
       DisplayName, `
       samaccountname, `
       userprincipalname, `
       employeenumber, `
       employeeid, `
       givenname, `
       @{"Label"="lockedOut";e={([int]$_.lockoutTime)}}, `
       surname, `
       homeDirectory, `
       mail, `
       @{"Label"="gafemail";e={$_.extensionAttribute12}}, `
       @{"Label"="gafeou";e={$_.extensionAttribute14}}
} catch {
    write-host ($_.Exception.Message);
    @{"users" = @()} | ConvertTo-Json
}
if ($users.count -eq 0 -or $users -eq $null) {
  @{"users" = @()} | ConvertTo-Json
} else {
  @{ "users" = $users} | ConvertTo-Json
}
