## Script de backup de arquivos de uma Origem para um Destino
## O Script faz backup de acordo com a ultima data de modificação.
## Testa a igualdade dos arquivos, verifica a ultima modificação do archive
## Se o arquivo tiver o mesmo nome altera a inicial para a data de execução do script
## No final copia o arquivo para o destino.

$thisDateAndTime = ("{0:yyyy-MM-dd}" -f (Get-Date))
$sourcePath = "C:\Users\suporte\Downloads"
$destinationPath = "C:\or"

# Obtendo arquivos e pastas da origem 
$entrySource = Get-ChildItem $sourcePath -Recurse

# Separando os Diretórios e Arquivos
$sourceFolders = $entrySource | Where-Object{$_.PSIsContainer}
$sourceFiles = $entrySource | Where-Object{!$_.PSIsContainer}

# Cria diretórios no Destindo igual a Origem
foreach($folder in $sourceFolders)
{
    $SrcFolderPath = $source -replace "\\","\\" -replace "\:","\:"
    $DesFolder = $folder.Fullname -replace $SrcFolderPath,$destinationPath
    if(!(test-path $DesFolder))
    {
        # Diretório ausente, cria ele
        Write-Host "O diretório $DesFolder, não existe. Criando..."
        new-Item $DesFolder -type Directory | out-Null
        Write-Host "Diretorio criado."
    }
}

# Copia os arquivos novos e modificados, adicionando a data atual no início do nome do arquivo modificado
foreach($archive in $sourceFiles)
{
    $SrcFullname = $archive.fullname
    
    $SrcFilePath = $sourcePath -replace "\\","\\" -replace "\:","\:"
    $DesFile = $SrcFullname -replace $SrcFilePath,$destinationPath 
    
    Write-Host "Verificando integridade do arquivo $Desfile "
    # Verifica se o archive existe no destino
    if(test-Path $Desfile)
    {
        
        #existe, compara data de modificação
        $SrcDate = get-Item $SrcFullname | foreach-Object{$_.LastWriteTimeUTC}
        $DesDate = get-Item $DesFile | foreach-Object{$_.LastWriteTimeUTC}
        # -gt = Greater than
        if($SrcDate -gt $DesDate)
        {

            # muda nome do arquivo que foi modificado / add data no início
            $DesDirectory = $archive.Directory -replace $SrcFilePath,$destinationPath 
            $DesFileModified = $DesDirectory +"\"+ $thisDateAndTime + "_" + $archive.Name

            #copia o arquivo com novo nome (versionamento)
            Write-Host "Arquivo $archive igual, o nome foi modificado, copiando para $DesFileModified"
            copy-Item -path $SrcFullName -dest $DesFileModified -force
        }
        
    }
    else
    {
        # arquivo não existe, copia o arquivo para o destino
        Write-Host "$SrcFullname é novo, copiando para $DesFile"
        copy-Item -path $SrcFullName -dest $DesFile -force
    }

}
