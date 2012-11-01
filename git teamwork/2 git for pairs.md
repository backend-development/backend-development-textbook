!SLIDE smaller
# Pair Programming und git

We want the log to show who worked as a pair

          @@@ sh
          $ git log
          commit 38d4f10fe2fb3f4d13e12d75e70bc0a085f0753f
          Author: Brigitte Jellinek + Mr. Hyde <xhyde.lba@fh-salzburg.ac.at>
          Date:   Fri Sep 14 10:52:41 2012 +0200

This semester we will use:

          @@@ sh
          firstname lastname driver + firstname lastname navigator
          e-mail address of the navigator

!SLIDE incremental

# git config

see git config --help

* three Levels:
* for a single repository ./.git/config
* for one user ~/.gitconfig 
  * --global
* for the whole system /etc/gitconfig 
  * --system

!SLIDE smaller

# git config file

      @@@ 
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

!SLIDE smaller
# set the config 

just in the current repository, just for now.

          @@@ sh
          git config --replace-all user.name "firstname lastname + firstname lastname"
          git config --replace-all user.email "navigator@gmail.com"

!SLIDE
# let's do it!
