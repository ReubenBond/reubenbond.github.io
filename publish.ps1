param (
  [string]$Token,
  [string]$UserName,
  [string]$Repository
)

$localFolder = "gh-pages"
$repo = "https://$($UserName):$($Token)@github.com/$($Repository).git"
git clone $repo --branch=gh-pages $localFolder

$from = "output\*"
$to = $($localFolder)
Copy-Item $from $to -recurse

Push-Location $localFolder
Write-Host "adding"
git add *
Write-Host "committing"
git commit -m "Update."
Write-Host "pushing"
git push --repo=$repo -f -v
Write-Host "done"