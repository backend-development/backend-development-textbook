!SLIDE title-slide subsection

# web performance


!SLIDE incremental

# pre-modern area

* performance of the backend
* myths about performance: image slicing


!SLIDE incremental 

# modern area

* work of the "exceptional performance" group at yahoo: yslow
* Souders(2007): High Performance Web Sites
* "front end view" of performance

!SLIDE incremental smaller

# Rules...

*   Less HTTP Requests
*   Use a Content Delivery Network
*   Avoid empty src or href
*   Add an Expires or a Cache-Control Header
*   Gzip Components
*   Put StyleSheets at the Top
*   Put Scripts at the Bottom
*   Avoid CSS Expressions...


!SLIDE incremental smaller

# ...Rules...

*   Make JavaScript and CSS External
*   Reduce DNS Lookups
*   Minify JavaScript and CSS
*   Avoid Redirects
*   Remove Duplicate Scripts
*   ...

!SLIDE incremental

# rails can help

* Minify JavaScript and CSS
* Create CSS Sprites
* Set Expires Header for static assets


