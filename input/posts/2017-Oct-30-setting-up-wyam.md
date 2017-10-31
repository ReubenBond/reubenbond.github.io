Title: Deploying Wyam Via Visual Studio Online
Published: 10/30/2017
Tags: ['Wyam', 'Visual Studio Online', 'Blog']
---

Here goes nothing! This blog is built with [Dave Glick's](https://twitter.com/daveaglick) [Wyam](https://wyam.io/) static site generator and deployed from a git repo in Visual Studio Online to GitHub Pages.

Here's how I set it up.

Requirements:
 * A Visual Studio Online repository for your blog source. You could have VSO pull the source from GitHub or somewhere else, instead.
 * A GitHub pages repo. I created a repository called [`reubenbond.github.io`](https://github.com/ReubenBond/reubenbond.github.io) under my profile, [`ReubenBond`](https://github.com/ReubenBond/). You'll be pushing compiled sources to the master branch of that repo.
 * Cake so you can test it out locally. Install it via [Chocolatey](https://chocolatey.org/): `choco install cake.portable`

 Steps:
 1. Create a repository for your blog source in Visual Studio Online.
 2. Add a new, empty build definition 

# Kick-starting Wyam with Cake

Create a file called `build.cake` in the root of your repo with these contents:
 ```C#
#tool nuget:?package=Wyam
#addin nuget:?package=Cake.Wyam

var target = Argument("target", "Default");

Task("Build")
    .Does(() =>
    {
        Wyam(new WyamSettings
        {
            Recipe = "Blog",
            Theme = "CleanBlog",
            UpdatePackages = true
        });
    });
    
Task("Preview")
    .Does(() =>
    {
        Wyam(new WyamSettings
        {
            Recipe = "Blog",
            Theme = "CleanBlog",
            UpdatePackages = true,
            Preview = true,
            Watch = true
        });        
    });

Task("Default")
    .IsDependentOn("Build");    
    
RunTarget(target);
```

Add a file called `config.wyam` like so:
```C#
#recipe Blog
#theme CleanBlog

Settings[Keys.Host] = "yourname.github.io";
Settings[BlogKeys.Title] = "MegaBlog";
Settings[BlogKeys.Description] = "Blog of the Gods";
```

Create a folder called `input` and add a folder called `posts` inside that.
Now create `input/posts/fist-post.md`:
```md
Title: Fist Post! A song of fice and ire
Published: 10/30/2017
Tags: ['Fists']
---

This post is about fists and how clumpy they always are.
```

Great! Try running it using Cake. Because Wyam targets an older version of Cake at the time of writing, I'm adding the `--settings_skipverification=true` option so that Cake doesn't complain.
```
cake --settings_skipverification=true -target=Preview
```
Open a browser to http://localhost:5080 and see the results.

# Automating Deployment

Add a new file called `publish.ps1` to the root of your repo with these contents:
```powershell
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

Set-Location $localFolder
git commit -am.
git push
```