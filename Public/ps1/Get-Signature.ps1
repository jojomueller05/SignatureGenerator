 #Get-Signature.ps1     #
 #Joël Julien Müller    #
 #______________________#
function Get-Signature {
    param (
        [string]
        $User
    )
    if ($User) {
        $config = parseConfig
        $theoreticalPath = $config.dfs.replace("%username%", $User)

        if (Test-Path -Path $theoreticalPath) {
            $signatureItems = Get-ChildItem -Path $theoreticalPath

            $signatures = $signatureItems | Select-Object BaseName, CreationTime, LastWriteTime | Group-Object BaseName | ForEach-Object { $_.Group[0] }
            
            $output = @()

            foreach ($signature in $signatures) {
                $singleSignature = @{
                    Name       = $signature.BaseName
                    CreatedAt  = $signature.CreationTime
                    LastChange = $signature.LastWriteTime
                }
                $output += $singleSignature
            }
            return $output
        } 
    }
    else {
        $config = parseConfig
        $dfsSplit = $config.dfs.split("\%")
        $dfsRoot = $dfsSplit[0]
        
        if (-not (Test-Path -Path $dfsRoot)) {
            Write-Error "Error: Cloudn't find the Path: $dfsRoot"
            return
        }
        
        $UPMProfiles = Get-ChildItem -Path $dfsRoot
        $users = @()
        
        foreach ($folder in $UPMProfiles) {
            $theoreticalPath = $config.dfs.replace('%username%', $folder.BaseName)
                
            if (Test-Path -Path $theoreticalPath) {
                    
                $signatureItems = Get-ChildItem $theoreticalPath
                $signatures = $signatureItems  | Select-Object BaseName, CreationTime, LastWriteTime | Group-Object BaseName | ForEach-Object { $_.Group[0] }
        
                $userObject = @{}
                $userObject[$folder.BaseName] = @()
        
                foreach ($signature in $signatures) {
                    $singleSignature = @{
                        Name       = $signature.BaseName
                        CreatedAt  = $signature.CreationTime
                        LastChange = $signature.LastWriteTime
                    }
                    $userObject[$folder.BaseName] += $singleSignature
                }
                $users += $userObject
            } 
        }
        return $users
    }
}