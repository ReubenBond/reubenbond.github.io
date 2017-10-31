param (
  [string]$Token,
  [string]$UserName,
  [string]$Repository
)

Set-Location "gh-pages"
git clone "https://$($UserName):$($Token)@github.com/$($Repository).git" --branch=master ./

Copy-Item ../output/* ./ -recurse
git commit -am.
git push