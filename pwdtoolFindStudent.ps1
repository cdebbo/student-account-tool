# validate user
try {
  $username = $PoSHUsername.split('\\')[1]
  if (((Get-ADGroupMember "All Permanent Staff" -Recursive).name -contains $(get-aduser $username).Name) -eq $false) {
    @{"users" = @()} | ConvertTo-Json
    return
  }
} catch {
  write-host ($_.Exception.Message);
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
