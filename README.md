Student Password Reset and Unlock

This tool uses the PowerShell web server (www.poshserver.net)

Posh provides authentication and very easily integrates with common Windows activities - in this cases resetting student passwords

Comments

1. Place the files in a single directory underneath the http root. 
2. Run Posh with -SSL flag. You can use a self-signed cert if you don't have a public one.
3. Modify the code if necessary to accommodate any particular OU or attribute settings to search for students.
4. All Active-Directory actions occur with the credentials of the logged in user. Nothing occurs with elevated permissions. So, to make this work you will need to delegate permissions within AD for any one who uses this tool. You will need to delegate 'password reset' and 'unlock' (those are not the proper names)
