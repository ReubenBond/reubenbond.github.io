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
git add *
git commit -m "Update."
git push
Pop-Location