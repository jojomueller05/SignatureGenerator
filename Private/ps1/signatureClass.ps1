 #signatureClass.ps1    #
 #Joël Julien Müller    #
 #______________________#
class signature {
    [string]$name
    [string]$path
    [string]$htmFile
    [string]$rtfFile
    [string]$txtFile
    hidden [string]$ogName

    # Constructor
    #Note: run here HTML to RTF converter function once?
    signature([string]$name, [string]$signaturePath){
        $this.name = $name
        $this.path = $signaturePath

        $fileExtensions = @(".txt", ".htm", ".rtf")
        $files = Get-ChildItem -Path $signaturePath -File | Where-Object {$_.Extension -in $fileExtensions}

        if ($files.Count -eq $fileExtensions.Count){
            foreach ($file in $files){
                switch ($file.Extension) {
                    ".rtf" {
                        $this.rtfFile = Get-Content $file.FullName -Raw -Encoding ansi
                    }
                    ".txt"{
                        $this.txtFile = Get-Content $file.FullName -Raw -Encoding ansi # sollte ansi sein
                    }
                    ".htm"{
                        $this.htmFile = Get-Content $file.FullName -Encoding UTF8
                        
                        $OGHtmlFile = Get-ChildItem $this.path | Where-Object {$_.Extension -eq ".htm"}
                        $this.ogName = $OGHtmlFile.BaseName
                    }
                }
            }
        } else {
            throw "Missing Signature files!"
        }
        
    }
    hidden [string]convertUmlauts2RTF([string]$String){

        # Umlaute korrigieren
        $String = $String -replace "À", "\'c0" `
                                -replace "Á", "\'c1" `
                                -replace "Â", "\'c2" `
                                -replace "Ã", "\'c3" `
                                -replace "Ä", "\'c4" `
                                -replace "Ç", "\'c7" `
                                -replace "È", "\'c8" `
                                -replace "É", "\'c9" `
                                -replace "Ê", "\'ca" `
                                -replace "Ë", "\'cb" `
                                -replace "Ì", "\'cc" `
                                -replace "Í", "\'cc" `
                                -replace "Î", "\'ce" `
                                -replace "Ï", "\'cf" `
                                -replace "Ñ", "\'d1" `
                                -replace "Ó", "\'d3" `
                                -replace "Ô", "\'d4" `
                                -replace "Ö", "\'d6" `
                                -replace "Ò", "\'d2" `
                                -replace "Ù", "\'d9" `
                                -replace "Ú", "\'da" `
                                -replace "Û", "\'db" `
                                -replace "Ü", "\'dc" `
                                -replace "à", "\'e0" `
                                -replace "á", "\'e1" `
                                -replace "â", "\'e2" `
                                -replace "ã", "\'e3" `
                                -replace "ä", "\'e4" `
                                -replace "ç", "\'e7" `
                                -replace "è", "\'e8" `
                                -replace "é", "\'e9" `
                                -replace "ê", "\'ea" `
                                -replace "ë", "\'eb" `
                                -replace "ì", "\'ec" `
                                -replace "í", "\'ed" `
                                -replace "î", "\'ee" `
                                -replace "ï", "\'ef" `
                                -replace "ñ", "\'f1" `
                                -replace "ó", "\'f3" `
                                -replace "ô", "\'f4" `
                                -replace "ö", "\'f6" `
                                -replace "ò", "\'f2" `
                                -replace "ù", "\'f9" `
                                -replace "ú", "\'fa" `
                                -replace "û", "\'fb" `
                                -replace "ü", "\'fc" `
                                -replace "ß", "\'df" `
    
        return $String
    }
    
    hidden [string]renderFile([string]$file, [string]$fileExtension, [object]$user){

        $ADuser = $user.data
        $ADuser.PSObject.Properties | ForEach-Object {
            $propertyName = $_.Name
            $propertyValue = $_.Value

            $replaceWord = "%%" + $propertyName + "%%"
            
            if($fileExtension -eq ".rtf"){
                $replaceWord = $this.convertUmlauts2RTF($replaceWord)
            }

            if ($file -match [regex]::Escape($replaceWord)){
                $file = $file.Replace($replaceWord, $propertyValue)
            }
        }
        $file = $file.Replace($this.ogName, $this.name)
        return $file
    }
    
    hidden [void]createFile([string]$content, [string]$fileExtension, [object]$user){
        try{
            $filePath = Join-Path -path $user.dfs -ChildPath ($this.name + $fileExtension)
            
            if($fileExtension -eq ".txt"){

                Set-Content $filePath -Value $content -Encoding ansi # sollte ansi sein
            } elseif($fileExtension -eq ".rtf"){
                

                Set-Content $filePath -Value $content -Encoding ansi # sollte ansi sein
            }else {
                
                Set-Content $filePath -Value $content -Encoding UTF8
            }
            
        }catch{
            Write-Host "Falied to create" + $fileExtension + " file!" -ForegroundColor red
        }
    }
    hidden [void]setACL([object]$user, [string]$path){
        if (Test-Path $path){
            $dir = Get-ChildItem $path -Recurse
    
            try {
                foreach($item in $dir){
                    $newAcl = Get-Acl -path $item.FullName
                    $argumentList = $user.SAMAccountName, "FullControl", "Allow"
    
                    $aclRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $argumentList
    
                    $newAcl.SetAccessRule($aclRule)
                    Set-Acl -path $item.FullName -AclObject $newAcl
                }
            }
            catch {
                Write-Host "Es ist ein Fehler aufgetreten:"
                Write-Host "Fehlermeldung: $($_.Exception.Message)" 
                Write-Host "StackTrace: $($_.Exception.StackTrace)"
            }
        }
    }

    [void]createSignature([object]$user) {
        try {
            #edit rtf file
            $newRtfFile = $this.renderFile($this.rtfFile,".rtf", $user)
            $this.createFile($newRtfFile, ".rtf", $user)

            #edit txt file
            $newTxtFile = $this.renderFile($this.txtFile,".txt", $user)
            $this.createFile($newTxtFile, ".txt", $user)

            #edit htm file
            $newHtmlFile = $this.renderFile($this.htmFile,".htm", $user)
            $this.createFile($newHtmlFile, ".htm", $user)
                     
            # create rtf file from HTML file
            $this.setACL($user.data, $user.dfs)
            Write-Host "Created Signature" $user.data.CN
        }
        catch {
        Write-Host "Error creating signature!" -ForegroundColor red
        }
    }

}
#usage:
#$signature = [signature]::new("test", "C:\Users\joel.mueller\data\signatures-02-11-2023\DE")