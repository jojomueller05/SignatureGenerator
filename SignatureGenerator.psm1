# Public Scripts
$Public = Join-Path -Path $PSScriptRoot -ChildPath ".\Public\ps1"
$PublicFiles = Get-ChildItem -Path $Public -Filter "*.ps1"

# Import Public Scripts
foreach ($PublicFile in $PublicFiles){
    . $PublicFile.FullName
}

# Private Scripts
$Public = Join-Path -Path $PSScriptRoot -ChildPath ".\Private\ps1"
$PrivateFiles = Get-ChildItem -Path $Public -Filter "*.ps1"

foreach ($PrivateFile in $PrivateFiles){
    . $PrivateFile.FullName
}

# Export Functions
Export-ModuleMember -Function Get-Signature, Remove-Signature, New-Signature