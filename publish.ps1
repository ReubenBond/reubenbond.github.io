param (
  [string]$Token,
  [string]$UserName,
  [string]$Repository
)

$localFolder = "gh-pages"
$repo = "https://$($UserName):$($Token)@github.com/$($Repository).git"
git clone $repo --branch=master $localFolder

Copy-Item "output\*" $localFolder -recurse

Set-Location $localFolder
git add *
git commit -m "Update."
git push