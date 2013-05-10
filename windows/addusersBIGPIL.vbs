Dim objRootLDAP
Dim mTab

' ------ SCRIPT CONFIGURATION ------
users_source = "usersBIGPIL.txt"

' ------ END CONFIGURATION ---------

Dim filesys, readfile, contents
set filesys = CreateObject("Scripting.FileSystemObject")
set readfile = filesys.OpenTextFile(users_source, 1, false)

compteur = 0

do while readfile.AtEndOfStream=false
    contents = readfile.ReadLine
    mTab = Split(contents, ";") 'nom=mTab(1), prenom=mTab(2), login=mTab(3), passwd=mTab(4)
		OU="OU=" & mTab(0) & "," 
    Set objRootLDAP = GetObject("LDAP://rootDSE")
		Set objContainer = GetObject("LDAP://" & OU & objRootLDAP.Get("defaultNamingContext"))

		'MsgBox "LDAP://" & OU & objRootLDAP.Get("defaultNamingContext")
    ' MsgBox mTab(0) & ";" & mTab(1) & ";" & mTab(2) & ";" & mTab(3)

    Set objUser = objContainer.Create("User", "cn=" & mTab(3))
    objUser.SetInfo
    objUser.Put "sAMAccountName", mTab(3)
  '  objUser.Put "sAMAccountType", 8053006368 
    objUser.Put "givenName", mTab(2)
    objUser.Put "sn", mTab(1)
    'objUser.Put "userPrincipalName", mTab(3) & "@bigmat.fr"
    objUser.SetInfo
    objUser.Put "displayName", mTab(2) & " " & mTab(1) 
    objUser.SetPassword mTab(4) 
    objUser.AccountDisabled = false
    objUser.SetInfo
    objUser.Put "userAccountControl", 66048
    objUser.SetInfo

		strProfilePath = "\\VM-AD01\Profils\%Username%"
		objUser.Put "profilePath", strProfilePath
		objUser.SetInfo		

    compteur = compteur + 1

loop
readfile.close

MsgBox compteur & " utilistateur(s) ajouté(s)"

WScript.Quit
