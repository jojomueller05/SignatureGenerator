 #Remove-Signature.ps1  #
 #Joël Julien Müller    #
 #______________________#
function Remove-Signature {
    param (
        [string]
        $User,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]
        $SignatureName
    )

    if($User){
        $config = parseConfig
        $userDfs = $config.dfs.Replace("%username%", $User)

        if(Test-Path $userDfs){
            deleteSignature $SignatureName $userDfs
        }
    } else {
        $config = parseConfig
        $dfsSplit = $config.dfs.split("\%")
        $dfsRoot = $dfsSplit[0]

        if (-not (Test-Path -Path $dfsRoot)) {
            Write-Error "Error: Cloudn't find the Path: $dfsRoot"
            return
        }
        $UPMProfiles = Get-ChildItem -Path $dfsRoot

        foreach($userFolder in $UPMProfiles){
            $theoreticalPath = $config.dfs.replace('%username%', $folder.BaseName)
                
            if (Test-Path -Path $theoreticalPath) {
                deleteSignature $SignatureName $theoreticalPath
            }
        }
    }
}