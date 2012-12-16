Git Teamwork
============

In this guide you will learn about a special form of teamwork
in programming: pair programming.

After reading this guide, you will:

* Know why you should try pair programming
* have a good starting point for your first try at pairing
* be able to use git while pairing

-------------------------------------------------------------------

Pair Programming
----------------

* two developers, one computer
* a lot of talking. talk first!
* "driver" is typing
* "navigator" watches, thinks ahead, spots errors, keeps the big picture in mind
* take turns, switch around roles, after 20 minutes

### why pair?

* pairs are more productive than single developers (see Williams(2000))
* better quality of life through contact with other humans
* learn from each other
* part of agile methodologies, used today in industry

### Pair Programming und git

We want the log to show who worked as a pair

``` sh
$ git log
commit 38d4f10fe2fb3f4d13e12d75e70bc0a085f0753f
Author: Brigitte Jellinek + Mr. Hyde <xhyde.lba@fh-salzburg.ac.at>
Date:   Fri Sep 14 10:52:41 2012 +0200
```

This semester we will use:

``` sh
firstname lastname driver + firstname lastname navigator
e-mail address of the navigator
```


### git config

see git config --help

* three Levels:
* for a single repository ./.git/config
* for one user ~/.gitconfig 
* --global
* for the whole system /etc/gitconfig 
* --system


### git config file

``` 
[user]
    name = Brigitte Jellinek + Mr. Hyde
    email = xhyde.lba@fh-salzburg.ac.at

[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
    ignorecase = true

[remote "origin"]
    url = ssh://repos.mediacube.at/opt/git/webpm/r1
    fetch = +refs/heads/*:refs/remotes/origin/*
```

### set the config 

just in the current repository, just for now.

``` sh
git config --replace-all user.name "firstname lastname + firstname lastname"
git config --replace-all user.email "navigator@gmail.com"
```

go do it!
