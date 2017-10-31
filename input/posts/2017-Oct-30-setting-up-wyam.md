Title: Deploying Wyam Via Visual Studio Online
Published: 10/30/2017
Tags: ['Wyam', 'Visual Studio Online', 'Blog']
---

Here goes nothing! This blog is built with [Dave Glick's](https://twitter.com/daveaglick) [Wyam](https://wyam.io/) static site generator and deployed from a git repo in Visual Studio Online to GitHub Pages.

Here's how I set it up.

# Preamble: Requirements
 * A Visual Studio Online repository for your blog source.
   * You could have also VSO pull the source from GitHub or somewhere else instead, but I haven't covered that here.
 * A GitHub repository which will serve the compiled output via GitHub Pages.
   * I created a repository called [`reubenbond.github.io`](https://github.com/ReubenBond/reubenbond.github.io) under my profile, [`ReubenBond`](https://github.com/ReubenBond/).
 * Cake so you can test it out locally. Install it via [Chocolatey](https://chocolatey.org/): `choco install cake.portable`

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
Open a browser to http://localhost:5080 and see the results. Editing the file while cake is running the Preview should cause your browser to refresh whenever you save changes.

# Automating Deployment

1. Install the [Cake build task from the Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=cake-build.cake) into VSO.
2. In Visual Studio Online, create a new, empty build for your repo, selecting an appropriate build agent.
3. Add the Cake Build task.
4. Select the `build.cake` file from the root of your repo as the *Cake Script*.
5. Set the *Target* to `Default`.
6. Optionally add the `--settings_skipverification=true` option to *Cake Arguments*.
7. Add a new *PowerShell Script* build task, set *Type* to `Inline Script` and add these contents:
```powershell
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
```
8. Create a new GitHub Personal Access token from GitHub's Developer Settings page, or by [clicking here](https://github.com/settings/tokens/new). I added all of the `repo` permissions to the token.
9. In VSO, add arguments for the script, replacing `TOKEN` with your token and replacing the other values as appropriate:
```
-Token TOKEN -UserName "ReubenBond" -Repository "ReubenBond/reubenbond.github.io"
```
10. Up on the *Triggers* pane, enable Continuous Integration.
11. Click *Save & queue*, then cross your fingers.

Hopefully that's it and you can now add new blog posts to the `input/posts` directory.