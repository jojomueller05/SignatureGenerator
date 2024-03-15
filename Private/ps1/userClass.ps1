 #userClass.ps1         #
 #Joël Julien Müller    #
 #______________________#
class user {
    hidden [object]$config
    [object]$data
    [string]$dfs

    user([string]$SAMAccountName, [object]$config){
        try {

            $this.config = $config
            $this.setData($SAMAccountName)


            $dfsPath = $this.config.dfs
            $dfsUserPath = $dfsPath.Replace("%username%", $SAMAccountName)

            $checkDfsUserPath = Test-Path -Path $dfsUserPath
            
            if ($checkDfsUserPath -eq $true){
                $this.dfs = $dfsUserPath
            } else {
                throw 
            }
            Write-Host "Created user Object" $this.data.CN
        }
        catch {
            Write-Error -Message "Error: Make sure, that the username is correct, the dfs path exists and the connection to the LDAP Server!" -Category InvalidData
        }

    }

    hidden [void]setData([string]$SAMAccountName){
        $ADuser = Get-ADUser -Identity $SAMAccountName -Properties *

        $newData = [PSCustomObject]@{}

        $ADuser.PSObject.Properties | ForEach-Object{
            $propertyName = $_.Name
            $propertyValue = $_.Value

            if ($null -eq $propertyValue){
                $propertyValue = "%%" + $propertyName + "%%" 
            }

            $newData | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyValue
        } 

        $this.data = $newData
    }
    
 }

# #usage:

# $entryPoint = Get-Location
# Set-Location $PSScriptRoot

# . ".\functions.ps1"
#  $config = parseConfig

#  $user = [user]::new("joel.mueller", $config)

# Set-Location $entryPoint