Git Rebasing
=============

This Guide will elaborate on teamwork in git
and using branches.

After reading this guide, you will know:

* How to rebase your branch

----------------------------------------------------------------

How git works
---------

### What is a commit, what is a branch.

Every commit is just a small change that
points to the commit before.

A branch is just a pointer to a certain commit.

If you create a branch called `a3` and add
a few commits W, X, Y, and Z to it, it might look like this:

![](images/git_branch.svg)

If you merge back into main now everything will be fine.

But what if the main branch moves on?


### Merging two branches

Let's say three other commits are added to the main: B, C and D:

![](images/git_branches.svg)

If you merge this, the merge might get complicated.
A new Commit is created that contains all the necessary changes:

![](images/git_merge.svg)

### Rebasing a branch


But there's a better approach: First you rebase your branch onto the main:

```
git checkout a3
git rebase main
```

This will try to apply the new commits in a4 on top
of the current state of main, leading to this situation:

![](images/git_rebase.svg)

After the rebase a merge into main will be simple.


### Rebase your feature branch

When working with feature branches you try to merge as fast as possible.
But if the main branch moves on while you are working on your feature,
you can use `git rebase` to catch up:


```shell
git fetch
git checkout a3
git pull origin a3
git rebase main
# fix problems, run test, fix problems again
git push -f origin a3  # overwrite branch with rebased branch
# work on your merge request
```


### Resources

* [Git Book: Chapter 3.6](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)
