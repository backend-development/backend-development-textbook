!SLIDE title-slide subsection

# Local Git

!SLIDE incremental smaller

# all git repositories are created equal in dignity and rights

* we've been using a centralized model, pushing to a remote on repos.mediacube.at
* today we need two working copies, but we can't push to the `origin`
* clone a local git repository:
* `git clone /path/to/the/repository new_directory_name`
* origin will point back to old repository
* push and pull as usual!

!SLIDE smaller

# example app 'rezepte'

     @@@
     cd /my/work
     git clone ssh://repos.mediacube.at/opt/git/web_2012/example/rezepte.git/ rezepte_development
     git clone /my/work/rezepte_development rezepte_production


!SLIDE 

# remember!

every significant step in development should be a commit!
