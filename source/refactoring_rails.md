Refactoring Rails
=======================

This guide will show you how to refactor
your code.  

By referring to this guide, you will be able to:

* Get to know some tools that help you find problematic aspects of your code
* Learn general refactoring practice from concrete examples

---------------------------------------------------------------------------

Refactoring
----------

Never be ashamed of making you code better.  On the contrary: recognizing code smells
in your old code means that you learnt something in the meantime.
Only very inexperienced people think that the code they wrote yesterday is
perfect.


Refactoring is 

* restructuring an existing body of code
* altering its internal structure
* without changing its external behavior [wikipedia](http://en.wikipedia.org/wiki/Refactoring)

We will use **tests** to ensure that we do not change the external behavior 
of the code we are refactoring.

A **code smell** is a piece of bad code that we recognize.

Read the Ruby version of Fowlers refactoring book to 
learn both code smells and refactorings:

Code Smells
--------

This is the list of code smells from 
Fields, Harvie, Fowler(2010): Refactoring, Ruby Edition. Addison-Wesley.
In chapter 6 to 12 of that book they describe refactorings to handle
all these problems and more:

* Duplicated Code
* Long Method
* Large Class
* Long Parameter List
* Divergent Change
* Shotgun Surgery
* Feature Envy.
* Data Clumps.
* Primitive Obsession
* Case Statements
* Parallel Inheritance Hierarchies
* Lazy Class.
* Speculative Generality.
* Temporary Field
* Message Chains
* Middle Man
* Inappropriate Intimacy
* Alternative Classes with Different Interfaces.
* Incomplete Library Class
* Data Class
* Refused Bequest
* Comments
* Metaprogramming Madness
* Disjointed API
* Repetitive Boilerplate

Tools for Code Quality
--------

Recognizing code that is problematic and should be refactored
is one of the main skills of a developer.  Often it is not a
black and white situation: there might be several ways of writing
a certain piece of code, each with it's own pros and cons.  
A tool cannot help you make these decision.

But there is a role for tools in this process: especially when
faced with a lot of code there are tools that can help
you find places you should look at.

A [code metric](http://en.wikipedia.org/wiki/Software_metric) is 
a quantitive measure of the quality of a piece of code.

The Gem `metric_fu` combines some metrics. Install it in your
Gemfile, and add a task-file, and run it on the command line `metriy_fu`.
It will generate a report in `tmp/metric_fu/output/`. 

**Saikuro** is a good place to start reading the report: it
measures  cyclomatic complexity, or how deep you nest your control structures.

See [Rails Cast no
166](http://railscasts.com/episodes/166-metric-fu?view=asciicast) for a more
detailed introduction to metric_fu.

Another tool to help find spots where you can improve the quality of
your code is `rails_best_practices`.  Install the gem, but don't put
it in your `Gemfile`.  Just run `rails_best_practices -f html` in
the main directory of your app.  The result will be written to 
`./rails_best_practices_output.html`.


Futher Reading
------

* Fowler, Beck, Brant, Opdyke, Roberts(1999). Refactoring: improving the design of existing code. Addison Wesley. ISBN: 0-201-48567-2.
* Fields, Harvie, Fowler(2010): Refactoring, Ruby Edition. Addison-Wesley.
* [codemod](https://github.com/facebook/codemod) a python script 
