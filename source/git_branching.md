Git Branching
=============

This Guide will focus on teamwork in git 
and using branches.

After reading this guide, you will know:

* How to merge your changes and your teammates changes
* How to create a branch
* How to merge your branch back into master

----------------------------------------------------------------

Branching and Merging
---------------------

When you create a branch in the repository you enable two
different development directions.  later on you might want to
merge the branches again, or you might want to discard one.

Different tools offer visual displays of these branches,
here a screenshot from SourceTree:

![SourceTree branches](images/source-tree-branches.png)

### Branching

To create or delete a branch use the `branch` command:

``` sh
git branch -v # shows branches + last commits
* master 7a98805 Merge branch 'iss49'
  iss50  782fd34 add scott to the author list in the readmes

# create a branch 
git branch BRANCH_NAME

# delete a branch
git branch -d BRANCH_NAME
```

Creating and deleting branches in itself doenst not do anything.
To actually use a branch you have to check it out:

``` sh
# switch to a different branch
git checkout BRANCH_NAME

# shortcut: create a new branch + checkout
git checkout -b foo
```

If this is a new, newly created branch, the files in your
working copy do not change.  you can now work in this
branch as usual: add, commit, add, commit.  
Now the branch is really different from other branches.
If you check out another branch now you will see the
files in your filesystem change!

Only checkout another branch when your working directory is clean,
after you have commited all changes!

### Behind the scene of a branch

before we branch

![no branches yet](images/branch-and-merge-1.svg)

### create a new branch 

``` sh
$git checkout -b iss53
```

![no branches yet](images/branch-and-merge-2.svg) 

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

![worked on both branches](images/branch-and-merge-3.svg)

![what do I want to merge?](images/branch-and-merge-4.svg)

### merge!

``` sh
$ git checkout master
$ git merge iss53
Merge made by recursive.
 README |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)
```

### done
![after the merge](images/branch-and-merge-5.svg)

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

### Resources 

[Git Book: Chapter 3.2](http://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging)
[Ry's git tutorial: Branches 1](http://rypress.com/tutorials/git/branches-1.html)
[Ry's git tutorial: Branches 2](http://rypress.com/tutorials/git/branches-2.html)

