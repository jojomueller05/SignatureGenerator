 #functions.ps1         #
 #Joël Julien Müller    #
 #______________________#
 function parseConfig(){
    $ModuleBase = $MyInvocation.MyCommand.Module.ModuleBase
    $ConfigFile = Join-Path -Path $ModuleBase -ChildPath 'Public/config.json'
    
    try{
        $json = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        return $json
    } catch {
        throw "Error: Failed parsing config.json!"
    }
 }

function deleteSignature([string]$name, [object]$userDfsPath){
    try{
        $items = Get-ChildItem -path $userDfsPath

        foreach($item in $items){
            if ($item.Name -match [regex]::Escape($name)){
                Remove-item -path $item.FullName -Recurse -Force 
                Write-Host "deleted" $item.FullName
            }
        }
    } catch{
        throw "faild deleting signature!"
    }    
      
}

function isVaildTemplate([string]$TemplatePath, [string]$TemplateName){

    $FilesToCheck = @("$TemplateName.htm", "$TemplateName.rtf", "$TemplateName.txt")
    
    if (-not (Test-Path -Path $TemplatePath)) {
        Write-Error "Error: Cloudn't find the Path: $TemplatePath"
        return
    }

    $TemplateFiles = Get-ChildItem $TemplatePath -File
    $NumberOfSpecifiedFiles = ($TemplateFiles | Where-Object { $FilesToCheck -contains $_.Name }).Count

    if($NumberOfSpecifiedFiles -eq 3){
        return $true
    } else {
        return $false
    }
}