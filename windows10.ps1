
#Finding files
$path = Read-Host -Prompt 'Input what path you want to search'
$extensions = Read-Host -Prompt 'Input what extensions you want to search for'
Get-childitem -Path $path -Recurse -ErrorAction -Include $extensions SilentlyContinue
