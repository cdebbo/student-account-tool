import-module ActiveDirectory
write-host ("loaded module. looking for user = " + $PoSHUserName)
# validate user
import-module "C:\Program Files\PoSHServer\webroot\http\pwdtool\pwdtool-utils.psm1"
$username = $PoSHUsername.split('\\')[1]
$r = validateUser -username $username -group "All Permanent Staff"
if (! $r.valid) {
  @{"poshusername" = ""} | ConvertTo-Json
  return
}

write-host ("valid group: user = " + $PoSHUserName)
Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : logged in.")
@{ "poshusername" = $PoSHUserName} | ConvertTo-Json

