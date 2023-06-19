# Next.js

Next.js is a framework for react
that also includes backend functionality.

After working through this guide you should

- know how to build server rendered pages in next.js
- know how to build api endpoints in next.js


---

## What is next.js?

Next.js is an open source framework, but it is mainly developed by Vercel.
Vercels business is platform a service. They published next.js in 2016.
React documentation mentions Next.js among "Recommended Toolchains"
since at least 2021.


## What does it offer?

Next.js gives you a folder structure for you application,
and several different ways to render webpages:

* statics webpages that are rendered once, server side.
* api endpoints
* server render pages that are served as HTML, but can be refreshed.
* React Server Components, where you can mix client and server side components in a tree

## The missing persistance layer

Next.js is not a full backend framework. For example it does not offer
ORM or another persistance layer.  There is good documentation for
combining nextjs with

* [superbase](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs), which offers postgres as a service
* [apollo](https://www.apollographql.com/blog/apollo-client/next-js/how-to-use-apollo-client-with-next-js-13/), which offers graphql
* [prisma](https://www.prisma.io/nextjs), a ORM for typescript or javascript

## next.js as a Static Site Generator

You can use `next.js` like `jekyll`, `eleventy` or `gatsby` as a [static
site generator](https://jamstack.org/generators/): during build time, html files are generated and can
then be served by a minimal webserver without backend capabilities.

This is the classic [Jamstack](https://jamstack.org/) (where JAM stands for JavaScript, API and Markup).


See [Static Site Generation (SSG)](https://nextjs.org/docs/pages/building-your-application/rendering/static-site-generation)


## See Also

- [Next.js Documentation](https://nextjs.org/docs)
- [nexttick](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/)
- [Event Loop Implementation](https://stackoverflow.com/questions/19822668/what-exactly-is-a-node-js-event-loop-tick)
- [set the event pool size process.env.UV_THREADPOOL_SIZE](http://docs.libuv.org/en/v1.x/threadpool.html)
- [V8 needs 4 threads](https://github.com/nodejs/node/blob/278a9267ec41f37e6b7dda876c417945d7725973/src/node.cc#L3964-L3965)
