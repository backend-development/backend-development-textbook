Git Branching
=============

This Guide will introduce you to using branches in git.

After reading this guide, you will know:

* Why you should a version control system like git
* How to create and merge branches

----------------------------------------------------------------

What is a Revision Control System?
----------------------------------

Revision control (an aspect of software configuration management), is the management of changes to
documents, computer programs, large web sites, and other collections of
information.  [Wikipedia](http://en.wikipedia.org/wiki/Revision_control)

In other words: it's a tool that helps you with your code files, and
with several version of such files.

These systems are known under many names
* version control system (VCS)
* source code manager (SCM)
* revision control system (RCS)

In german they are most commonly called
* Versionskontrollsystem 


### A short - and incomplete - history 

Some ancient systems that are no longer in use are:

* RCS
* CVS

These systems are open source systems that are still in use today:

* SVN, also called Subversion
* Hg, also called Mercurial
* Git

### Why use revision control?

1. The whole history of the project always accessible
2. You can try out stuff without danger of breaking anything
3. For teamwork - several people can program on separate computers, the system helps with merging the differnet codes

### Why use git?

![background](images/linus-torvalds.jpg)
photo [cc](http://www.flickr.com/photos/48923114@N00/116787425)

1. git was invented by linus torvalds, see [this video of a talk by him](http://www.youtube.com/watch?v=4XpnKHJAok8)
2. is is used to manage the linux kernel
3. git is a distributed vcs
4. you can work online and offline 
5. its architecture is not fixed: e.g. move to new central server
6. branching and merging is easy
7. all the data is saved in only one directory: .git
8. integrity of the code: identified by SHA1

### Why use github.com?

1. it's free for open source projects
2. it offers a convenient web interface
3. with forking + pull requests it offers a good way how to contribute to open soruce projects
4. it's mascopt is cute: octocat ![octocat](images/octocat.png)

### Resources for Learning Git

* [http://git-scm.com/documentation](http://git-scm.com/documentation)
* [http://progit.org/book/](http://progit.org/book/)
* [http://help.github.com/](http://help.github.com/)
* Loelinger(2009): Version Control with Git. O'Reilly Media.
* Swicegood(2009): Pragmatic Version Control Using Git. Pragmatic Bookshelf.


Git Basics 
----------

Where is my code?  There are four answers to this question, for "places" that
you need to learn about:

![git-transport](images/git-where.png)

* the workspace is what you see in your on file system
* the index is an invisible space where you can *add*  files you want to commit
* you can always commit to your local repository - it's really stored in the *.git* folder
* the remote repository may not be reachable all the time


### Configuring Git

* command "git config"
* for project: stored in .git/config
* for user: is stored in ~/.gitconfig
* use flag --global for user


``` sh
$ git config --global user.name "Firstname Lastname"
$ git config --global user.email "me@fh-salzburg.ac.at"
$ git config --list --global
# user.name=Firstname Lastname
# user.email=me@fh-salzburg.ac.at
```

### Create a Repository from scratch

``` sh
cd project_directory
git init
# creates subdirectory .git
# repository is stored in there
# .git/config 
```


Windows Only: line breaks?

Some configs you might want to set

``` sh
core.autocrlf false
core.editor "C:/Programme/Notepad++/Notepad++.exe"
```

Aliases

``` sh
git config --global alias.co checkout

# you now can use
git co master
# instead of
git checkout master
```

### Plain git Workflow


``` sh
# what's up?
git status

# i've edited a file
git add FILE

# i've edited a lot of files
git add .

git commit -m "describe the commit"
```

### Index / Staging area
![git-index](images/git-index.png)

Workspace ("working copy") is managed by git!


### content, not file!

``` sh
# change file
git add file
# change file again
git status
git diff
git diff --staged 
```

*the first change has beed staged, but not the second!*

### delete file

* deleting file from workspace alone is not enough
* opposite of "git add" is "git rm"

``` sh
git rm FILE
```

### rename file

``` sh
git mv SOURCE DESTINATION
```

### remotes

````SH
git add remote origin https://github.com/myname/myrepository.git
```


### clone an existing repository

``` sh
git clone REPOSITORY_URL
git clone REPOSITORY_URL DIR_NAME
```

* implicitly sets

``` sh
git remote add origin REPOSITORY_URL
```

### add a remote 

``` sh
git remote add REMOTE_NAME REMOTE_URL

git remote add origin ssh://repos.mediacube.at/opt/git/username.git
git remote add github git@github.com:bjelline/web-engineering-textbook.git
```

### workflow with remote
![git-remote](images/git-remote.png)

### push

* specify local branch and remote repository

``` sh
git push origin master
```


### pull

* specify local branch and remote repository

``` sh
git pull origin master
```



Branching and Merging
---------------------

### Branching

``` sh
git branch -v # shows branches
* master 7a98805 Merge branch 'iss49'
  iss50  782fd34 add scott to the author list in the readmes

# create a branch 
git branch BRANCH_NAME

# delete a branch
git branch -d BRANCH_NAME

# get data from a different branch
git checkout BRANCH_NAME

# shortcut: create a new branch + checkout
git checkout -b foo
```

### Basic workflow
before we branch

![no branches yet](images/branching-1.png)

### create a new branch 

``` sh
$git checkout -b iss53
```

![no branches yet](images/branching-2.png)

### switch to a branch

``` sh
$git checkout iss53
```

### which branch am I on?

![git branch](images/git-branch.png)

### work

``` sh
# edit; commit(c3)
$ git checkout master 
# edit; commit(c4)
$ git checkout iss53
# edit; commit(c5)
```

![worked on both branches](images/branching-3.png)

![what do I want to merge?](images/branching-4.png)

### merge!

``` sh
$ git checkout master
$ git merge iss53
Merge made by recursive.
 README |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)
```

### done
![after the merge](images/branching-5.png)

### delete branch
``` sh
git branch -d iss53
```


### Merging in detail

``` sh
git merge OTHER_BRANCH
```

merge the OTHER_BRANCH into the current (checked-out) branch

### Conflicts

* when both branches contain changes for the same file
* or: trying two pushes containing changes for the same file

``` sh
$ git status
index.html: needs merge
# On branch master
# Changed but not updated:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#   unmerged:   index.html
#
```

### conflict markers in a file

``` html
</div>
<<<<<<< HEAD:index.html
<footer>contact: support@github.com</footer>
=======
<div id="footer">
  please contact us at support@github.com
</div>
>>>>>>> iss53:index.html
</body>
</html>
```

### conflict markers in a files

![conflict marker with syntax highlighting](images/conflict-markers.png)
### how to resolve
* for all files:
* edit file
* try out your changes!
* git add FILE
* git commit

### Do it!

[Chapter 3.2](http://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging)

