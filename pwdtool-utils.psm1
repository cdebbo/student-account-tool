# pwdtool utilities
import-module ActiveDirectory

# username = user we want to validate
# group = the user must be a member of this group in order to return true.
# permission = ignored for now.
function validateUser($username, $group, $permission) {
  try {
    #$username = $PoSHUsername.split('\\')[1]
    if (((Get-ADGroupMember $group -Recursive).name -contains $(get-aduser $username).Name) -eq $false) {
      return @{"valid" = $false; message = "Permissions Problem"}
    }
  } catch {
    write-host ($_.Exception.Message);
    return @{"valid" = $false; message = "Permissions Problem"}
  }
  return @{valid = $true; message = ""}
}

Export-ModuleMember -Function validateUser