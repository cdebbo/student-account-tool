# validate user
try {
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

#do this before installing the software
# New-EventLog -LogName Application -Source StudentServices
# Write-EventLog -LogName Application -Source StudentServices -EventId 5555 -Message "Reset Some Password" 

(get-eventlog -LogName Application -Source StudentServices) | ConvertTo-Html -Property Index,TimeGenerated,Message