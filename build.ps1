$credentialFile = "./creds.ps1"
$projectFile = "./project.json"
$directoryName= $(get-childitem $projectFile).Directory.Name

$toctemplate = Get-Content -raw $projectFile | convertfrom-json -AsHashtable
. $credentialFile

$v=$($toctemplate."Version")
$toctemplate."Version" = [version]::New($v.Major,0,$($v.Build+1),0)
$toctemplate | convertto-json | set-content $projectFile

##Generate Toc:
$tocoutput = "## Interface: {0}`r`n## Title: {1}`r`n## Author: {2}`r`n## Version: {3}`r`n## SavedVariables: {5}`r`n## SavedVariablesPerCharacter: {6}`r`n`r`n{4}" -f $($toctemplate.Interface), ($toctemplate.Title), ($toctemplate.Author), "$($toctemplate."Version")", ($toctemplate.packageFiles.luaFilename), ($toctemplate.SavedVariables -join ","), ($toctemplate.SavedVariablesPerCharacter -join ",")
remove-item -Recurse -force -Path "./$directoryName"

new-item -path $directoryName -ItemType Directory
if($?)
{
    Set-content -path "./$directoryName/$($toctemplate.packageFiles.tocFilename)" -value $tocoutput -force
    Copy-Item $($toctemplate.packageFiles.luaFilename) "./$directoryName/$($toctemplate.packageFiles.luaFilename)"
    Compress-Archive -Path $directoryName -DestinationPath $($toctemplate.packageFiles.luaFilename).replace(".lua","-$($toctemplate."Version").zip") -force
}
copy-item -Recurse -force ./$directoryName 'C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns'
#. $curseApiFile

# todo: upload file to curse as part of a pipeline

# there will be a chicken/egg issue with tracking version number. 
# Probably eventually move that to a manual process and use build/job numbers instead

