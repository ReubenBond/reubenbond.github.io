param (
  [string]$Token,
  [string]$UserName,
  [string]$Repository
)

$localFolder = "gh-pages"
git clone https://$($Token)@github.com/$($Repository).git --branch=gh-pages $localFolder

$from = "output\*"
$to = $($localFolder)
Copy-Item $from $to -recurse

Push-Location $localFolder
Write-Host "adding"
git add *
Write-Host "committing"
git commit -m "Update."
Write-Host "pushing"
git push 
Write-Host "done"