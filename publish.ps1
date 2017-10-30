param (
  [string]$Token,
  [string]$UserName,
  [string]$Repository
)

$localFolder = "gh-pages"
$repo = "https://$($UserName):$($Token)@github.com/$($Repository).git"
git clone $repo --branch=master $localFolder

$from = "output\*"
$to = $($localFolder)
Copy-Item $from $to -recurse

Push-Location $localFolder
git add *
git commit -m "Update."
git push --repo=$repo -f