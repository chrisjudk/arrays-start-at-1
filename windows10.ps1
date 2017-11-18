http://brandonpadgett.com/powershell/Local-gpo-powershell/

################################################################################################################


function Starting-Menu{ 
  Write-Host 'Choose an option:'
  Write-Host '1. Find a file'
  #Add new choices here
  
  $choice = Read-Host "Choose a choice"
  switch($choice){ #Read user input, choose from that
    "1" { Find-File }
    }
}

#Finding Files
function Find-File{
  $path = Read-Host -Prompt 'Input what path you want to search'
  $extensions = Read-Host -Prompt 'Input what extensions you want to search for'
  Get-childitem -Path $path -Recurse -ErrorAction -Include $extensions SilentlyContinue
}

Starting-Menu
