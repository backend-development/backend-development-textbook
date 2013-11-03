Refactoring Rails
=======================

This guide will show you how to refactor
your code.  All the examples were taken from
students projects. For all of them it was their
first rails project, and they all ended up with
a fully functional, finished project. The perfect
starting place for some refactoring.

By referring to this guide, you will be able to:

* Understand how testing can help you during refactoring
* Get to know some tools that help you find problematic aspects of your code
* Learn general refactoring practice from concrete examples

---------------------------------------------------------------------------

Never be ashamed...
------------------

of making you code better.  On the contrary: recognizing code smells
in your old code means that you learnt something in the meantime.
Only very inexperienced people think that the code they wrote yesterday is
perfect.


As we have [learned previously](/testing_and_refactoring.html) refactoring is 

* "restructuring an existing body of code
* altering its internal structure
* without changing its external behavior" [wikipedia](http://en.wikipedia.org/wiki/Refactoring)

We will use **tests** to ensure that we do not change the external behavior 
of the code we are refactoring.

### Tools for Code Quality

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
Gemfile, and add a task-file, `lib/tasks/metric_fu.rake`.
Sadly, three of the metrics have not been adapted for Ruby 1.9 yet,
so you have to disable them in `lib/tasks/metric_fu.rake`.

``` rake
begin
  require 'metric_fu'

  MetricFu::Configuration.run do |config|
    config.metrics -= [:reek, :flay, :flog]
  end

rescue LoadError
end
```

Run `rake metrics:all` and the results will be saved as html-files
in `tmp/metric_fu/output/`. **Saikuro** is a good place to start: it
measures  cyclomatic complexity, or how deep you nest your control structures.

See [Rails Cast no
166](http://railscasts.com/episodes/166-metric-fu?view=asciicast) for a more
detailed introduction to metric_fu.



Another tool to help find spots where you can improve the quality of
your code is `rails_best_practices`.  Install the gem, but don't put
it in your `Gemfile`.  Just run `rails_best_practices -f html` in
the main directory of your app.  The result will be written to 
`./rails_best_practices_output.html`.



Tools
-----

Most IDEs now have some refactorings built in.

* [codemod](https://github.com/facebook/codemod) a python script 
