# Powershell Signature Generator
Generate Signatures for Outlook from a template with data from Active Direcotry.

**Requirements:**
- Powershell `v7.4.0` or higher
- ActiveDirectory module
- UPMProfile stored on a Networkshare
- Admin Rights 

**Limitations:**
- Images must be accessible via uri

# Installation
After you've cloned the Repository, you can eather make the Module available for all users or for a single user.

**All Users:**
Move the Folder to `%ProgramFiles%\WindowsPowerShell\Modules`

**Single User:**
Move the Folder to `%UserProfile%\Documents\WindowsPowerShell\Modules`

You could also keep the folder where it is and use the Path to this folder to Import the module:
```powershell
 Import-Module <PathToThisFolder> -Force
```
You can check if it worked with following Command:
```powershell
Get-Command -Module SignatureGenerator
```
It should return 3 Functions:

# The configuration file
Now here it gets really important. Most Companies have stored the users `UPMProfile` somewhere on a Networkshare. In this Directory there should be multiple folders with the `SamAccountName` of the User. In the users folder there should also be the `Roaming\Microsoft\Signatures\` Folder.

To make this script work, you have to change the path in the [config.json](./Public/config.json) File. Here is a example:
```json
{
  "dfs": "\\\\intra.example.com\\dfs\\UPMProfiles\\%username%\\Win2019\\UPM_Profile\\AppData\\Roaming\\Microsoft\\Signatures"
}
```
make sure you replace the users`SamAccountName` with `%username%`. Otherwise the Module can't create the Path for other users.

# Outlook Signature
A Outlook Signature consists 3 Files:
- `.htm` 
- `.rtf`
- `.txt`

If you create a Signature in Outlook you wil also get a Folder for the Signature. But for this
Powershell module we recommend to store your Images on a Webserver and use the url to the Image in
the `href`.

# Creating a Template
To Create a Template you can create a Folder in [Public\templates](Public\templates) named after your Signature name.

After that you can create a `.htm` file and a `.txt` with your Signature.
> **Info:** The Foldername and the files in it should have the same name!

You can Insert datafileds from `Active Directory` using `%%` at the start and at the end. For example:
- `%%OfficePhone%%`
- `%%CN%%`
- ...

You can get a List of all Available Attributes with following command:
```powershell
Get-Aduser -Identity <YourSamAccountName> -Properties *
```
To create the `.rtf` file I would recommend you to open the `.htm` file with Word and export it as `.rtf`. Take a look at the [example](./Public/templates/example1/) as reference.

# Usage
To use the Module you have to Import it with the `Import-Module`. Now you have access to following three functions:

## Get-Signature
Use this Function to get the Signature of a single user or the Signatures of all useres.

**Single user:**
```powershell
Get-Signature -User <SamAccountName>
```
**All users:**
> **Info:** Is super slow...
```powershell
Get-Signature
```

## New-Signature
Use this function to generate a Signature for a Specific user.
```powershell
New-Signature -User <SamAccountName> -SignatureName <FolderNameOfSignature>
```

**Example:**
```powershell
New-Signature -User joel.mueller -SignatureName "example1"
```
## Remove-Signature
Remove Signature for a single user or for all users.

**Single user:**
```powershell
Remove-Signature -User <SamAccountName> -SignatureName <SignatureName>
```

**All users:**
> **Info:** Not tested yet
```powershell
Remove-Signature -SignatureName <SignatureName>
```

# Contributing 
Let me know if you have any suggestions for improvement.
