!SLIDE title-slide subsection

# code reuse in rails


!SLIDE incremental smaller

# views in views in views

* `app/views/layout/application.html.erb`  - the whole HTML document
* `app/views/<controllername>/<actionname>.html.erb` - the specific view
* `app/views/<controllername>/_form.html.erb` partial used by edit and new action
* `app/views/<controllername>/_*.html.erb` other partials you can create



!SLIDE incremental

# code reuse in views 

* `app/helpers/application_helper.rb` code you want to use in many views



!SLIDE incremental

# code reuse in controllers: filter

* `before_filter <methodname>`
* method is called before every action
* `before_filter <methodname>, :only => [:show, :edit, :update]`
* method is only called before the specified actions

!SLIDE incremental smaller

# code reuse in controllers: inheritance

* all your controller inherti from `app/controllers/application_controller.rb` 
* only the ApplicationController inherits from ActionController::Base
* = one class to configure things such as request forgery protection and filtering of sensitive request parameters.  


