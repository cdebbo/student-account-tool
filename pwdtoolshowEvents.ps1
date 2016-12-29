# validate user
<#
try {
# IT Support; All Permanent Staff
  $username = $PoSHUsername.split('\\')[1]
  if (((Get-ADGroupMember "IT Support" -Recursive).name -contains $(get-aduser $username).Name) -eq $false) {
    @{"validation_status" = "Permissions Problem"} | ConvertTo-Json
    return
  }
} catch {
  write-host ($_.Exception.Message);
  @{"validation_status" = "Permissions Problem"} | ConvertTo-Json
  return
}
#>
import-module "C:\Program Files\PoSHServer\webroot\http\pwdtoolv2\pwdtool-utils.psm1"
$username = $PoSHUsername.split('\\')[1]
$r = validateUser -username $username -group "IT Support"
if (! $r.valid) {
  @{"validation_status" = $r.message} | ConvertTo-Json
  return
}

#do this before installing the software
# New-EventLog -LogName Application -Source StudentServices
# Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message "Reset Some Password" 

(get-eventlog -LogName Application -Source StudentServices) | ConvertTo-Html -Property Index,TimeGenerated,Message