!SLIDE subsection

# git internals

!SLIDE

# where git stores data

* ./.git/objects/
* content is hashed,
* resulting hash-value used as directory + filename

!SLIDE
# hierarchy

* content
* files + folders
* commits

!SLIDE
# same content is never stored twice!

  @@@ sh
  $git cat-file -p 6799a8db8f353007435e12f898ac9e97477d935f
  100644 blob c16ab9ce6a5b5278c0621a31d6aa77dfb2534c3b    different.txt
  100644 blob 6bc4ddef08b181feb7dfb76565d0d4c7465e2db1    other.txt
  100644 blob 6bc4ddef08b181feb7dfb76565d0d4c7465e2db1    test.txt
