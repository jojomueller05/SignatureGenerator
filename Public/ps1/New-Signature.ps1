 #New-Signature.ps1     #
 #Joël Julien Müller    #
 #______________________#
function New-Signature {
    param (
        [string]
        $User,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]
        $SignaturName
    )
    $config = parseConfig
    
    $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
    $TemplatePath = Join-Path -Path $ModuleBase -ChildPath "Public\templates\$SignaturName"

    if(-not(isVaildTemplate $TemplatePath $SignaturName)){
        Write-Error "Error: Invalid Template: $SignatureName"
    } 

    $UserObject = [user]::new($User, $config)
    $SignaturObject = [signature]::new($SignaturName, $TemplatePath)

    $SignaturObject.createSignature($UserObject)
    
}