!SLIDE title-slide subsection

# compiling to css
# compiling to javascript


!SLIDE incremental

# compiling to css

* [sass](http://sass-lang.com/) - default in ruby
* [less](http://lesscss.org/)
* [stylus](http://learnboost.github.com/stylus/)

!SLIDE 

# no { } and no ;

    @@@
    h1
      color: black
      background-color: yellow

    p
      text-align: justify


!SLIDE 

# nesting

    @@@
    h1 strong
      color: red
    
    nav
      a:link, a:visited, a:active
        text-decoration: none
      a:link
        color: blue
      a:visited
        color: white

!SLIDE 

# variables and computation

    @@@
    $blue: #3bbfce
    $x: 16px

    .content-navigation
      border-color: $blue
      color: darken($blue, 9%)

    .border
      padding: $x / 2
      margin: $x / 2
      border-color: $blue


!SLIDE

# mixins for reusing css-code

    @@@
    @mixin left($dist)
      float: left
      margin-left: $dist

    #data
      @include left(10px)

!SLIDE

# automatically create sass from css after every change

    @@@
    # for one file in the current directory
    sass --watch style.scss:style.css

    # for a whole directory of files
    sass --watch stylesheets/sass:stylesheets/compiled

!SLIDE smaller

# sass comes with a reverse compiler

    @@@
    sass-convert --from css --to sass style.css > style.sass

