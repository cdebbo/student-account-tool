# validate user
import-module "C:\Program Files\PoSHServer\webroot\http\pwdtool\pwdtool-utils.psm1"
$username = $PoSHUsername.split('\\')[1]
$r = validateUser -username $username -group "All Permanent Staff"
if (! $r.valid) {
  @{"validation_status" = $r.message} | ConvertTo-Json
  return
}

#do this before installing the software
# New-EventLog -LogName Application -Source StudentServices
# Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message "Reset Some Password" 

$susername = $PoSHPost.susername
$spassword = $PoSHPost.spassword

# get credentials
$cred_username = $PoSHUsername

#write-host ("validate " + $spassword + " : " + $susername)
$status = @{ "validation_status" = "no valid action"}

try {
  Import-Module ActiveDirectory
  $domain = "kcdsb.on.ca"
  Add-Type -AssemblyName System.DirectoryServices.AccountManagement
  $ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
  $pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ct, $domain)
  if ($pc.ValidateCredentials($susername, $spassword)) {
    $IsValid = "This is the student's password"
  } else {
    $IsValid = "This is not the student's password"
  }
  Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username attempted to validate the account for $susername")
  $emaillog = "User {0} just attempted to validate the user account for student {1}" -f $cred_username,$susername
  Send-MailMessage -To ($cred_username.substring(6) + "@kcdsb.on.ca") -Subject "Validate Student Account Notification" -SmtpServer kcdsb-on-ca.mail.eo.outlook.com -from "accttool-noreply@kcdsb.on.ca" -body $emaillog 
  $status = @{ "validation_status" = $IsValid}

} catch {
  Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : Exception {0}" -f $_.Exception.Message)
  $status = @{"validation_status" = $_.Exception.Message}
}
$status | ConvertTo-Json