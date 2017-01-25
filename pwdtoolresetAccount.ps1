# validate user
import-module "C:\Program Files\PoSHServer\webroot\http\pwdtool\pwdtool-utils.psm1"
$username = $PoSHUsername.split('\\')[1]
$r = validateUser -username $username -group "All Permanent Staff"
if (! $r.valid) {
  @{"reset_status" = $r.message} | ConvertTo-Json
  return
}

#do this before installing the software
# New-EventLog -LogName Application -Source StudentServices
# Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message "Reset Some Password" 

$susername = $PoSHPost.susername
$spassword = $PoSHPost.spassword
$tpassword = $PoSHPost.tpassword
$reason = $PoSHPost.reason
$reset_action = $PoSHPost.action
$change_at_next_logon = $PoSHPost.change_at_next_logon

# get credentials
$cred_password = $tpassword | ConvertTo-SecureString -asPlainText -Force
$cred_username = $PoSHUsername
$credential = New-Object System.Management.Automation.PSCredential($cred_username,$cred_password)

#write-host ("action " + $reset_action + " : " + $sunlock + " : " + $spassword + " : " + $susername)
#write-host ("cred " + $credential)
$status = @{ "reset_status" = "no valid action"}

try {
  Import-Module ActiveDirectory
  # necessary Delegate Permissions are
  # "Read pwdLastSet", "Write pwdLastSet", 
  # "Read lockoutTime", "Write lockoutTime"
  # "Read UserAcctControl", "Write UserAcctControl"
  # "Reset Password"
  switch ($reset_action) { 
      "Disable" {
        Disable-ADAccount -Credential $credential -Identity $susername
        Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : disable account for $susername. reason: $reason")
        $emaillog = "User {0} just disabled the computer account for student {1} with reason: {2}" -f $cred_username,$susername, $reason
        Send-MailMessage -To ($cred_username.substring(6) + "@kcdsb.on.ca") -Subject "Enable/Disable Student Account Notification" -SmtpServer kcdsb-on-ca.mail.eo.outlook.com -from "accttool-noreply@kcdsb.on.ca" -body $emaillog 
        $status = @{ "reset_status" = "disabled"}
      }
      "Enable" {
        Enable-ADAccount -Credential $credential -Identity $susername
        Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : enable account for $susername. reason: $reason")
        $emaillog = "User {0} just enabled the computer account for student {1} with reason: {2}" -f $cred_username,$susername, $reason
        Send-MailMessage -To ($cred_username.substring(6) + "@kcdsb.on.ca") -Subject "Enable/Disable Student Account Notification" -SmtpServer kcdsb-on-ca.mail.eo.outlook.com -from "accttool-noreply@kcdsb.on.ca" -body $emaillog 
        $status = @{ "reset_status" = "enabled"}
      }
      "Unlock" {
        Unlock-ADAccount -Credential $credential -Identity $susername
        Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : unlock account for $susername")
        $emaillog = "User {0} just unlocked the computer account for student {1}" -f $cred_username,$susername
        Send-MailMessage -To ($cred_username.substring(6) + "@kcdsb.on.ca") -Subject "Reset or Unlock Student Account Notification" -SmtpServer kcdsb-on-ca.mail.eo.outlook.com -from "accttool-noreply@kcdsb.on.ca" -body $emaillog 
        $status = @{ "reset_status" = "unlocked"}
      }
      "Reset" {
        if ($spassword.length -gt 6) {
          $secureSpassword = ConvertTo-SecureString -AsPlainText $spassword -Force
          Set-ADAccountPassword -Credential $credential -Identity $susername -Reset -NewPassword $secureSpassword
          if ($change_at_next_logon -eq 'true') {
            Set-ADUser $susername -ChangePasswordAtLogon $true
            Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : change at next logon set to TRUE for student $susername")
          } 
          Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : reset password for $susername")
          $emaillog = "User {0} just reset the computer account password for student {1}" -f ($cred_username),$susername
          Send-MailMessage -To ($cred_username.substring(6) + "@kcdsb.on.ca") -Subject "Reset or Unlock Student Account Notification" -SmtpServer kcdsb-on-ca.mail.eo.outlook.com -from "accttool-noreply@kcdsb.on.ca" -body $emaillog 
          $status = @{ "reset_status" = "reset password"}
        } else {
          Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : failed reset password: invalid credentials")
          $status = @{ "reset_status" = "invalid password"}
        }
      }
      
  }
} catch {
  Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message $("User $cred_username : Exception {0}" -f $_.Exception.Message)
  $status = @{"reset_status" = $_.Exception.Message}
}
$status | ConvertTo-Json