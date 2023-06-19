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


## next.js routing

From `next.js` 13 onwards the routes are created in the `app/` directory.
`page.js` is the default (like index.html used to be), folders and
filenames can contain parameters in brackets:

```
app/page.js          -->   /
app/otherpage.js     -->   /otherpage
app/users/page.js    -->   /users/
app/users/[:id].js   -->   /users/42/
```

There are special files:


* `layout.js` for [nested layouts](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#nesting-layouts)
* `error.js`  for [error handling](https://nextjs.org/docs/app/building-your-application/routing/error-handling) with error boundaries

![](images/nested-layouts-ui.png)


## next.js as a Static Site Generator

You can use `next.js` like `jekyll`, `eleventy` or `gatsby` as a [static
site generator](https://jamstack.org/generators/): during build time, html files are generated and can
then be served by a minimal webserver without backend capabilities.

This is the classic [Jamstack](https://jamstack.org/) (where JAM stands for JavaScript, API and Markup).


See [Static Site Generation (SSG)](https://nextjs.org/docs/pages/building-your-application/rendering/static-site-generation)


* create a nextjs app
* in next.config.js add one or two values (see below)
* `npm run build`
* find the static files in folder `out/`

### next.config.js for static site generation

We must set `output` to `export` to enable static site generations.

For most Webserver for static pages we need to set `trailingSlash` to `true`.

If the site will be hosted in a subfolder, for example at http://bjelline.pages.mediacube.at/statixnextjs/
we must configure this as the basepath:

```
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  basePath: '/foldername',
}
```




### using github or gitlab pages

You can host your static files gitlab pages with the following configuration:
gitlab CI is used to build the pages, and the resulting folder `out` is declared
as an artifact.  Gitlab will pick up this artifact and serve it through its
pages webserver.


```
image: node

before_script:
  - npm install

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .next/cache/

pages:
  script:
    - npm run build
    - mv public old_republic
    - mv out public
  artifacts:
    paths:
      - public
  only:
    - main
```

## next.js for API endpoints

Use files called `route.js` as [route handlers](https://nextjs.org/docs/app/building-your-application/routing/router-handlers) to implement the endpoints.

```js
// file /app/greeting/route.js

import { NextResponse } from 'next/server'

export async function GET() {
  return NextResponse.json({ "hello": "world" })
}
```


## React Server Components

[How Server Components Work](https://www.plasmic.app/blog/how-react-server-components-work)

![](images/react-server-components.png)

## See Also

- [Next.js Documentation](https://nextjs.org/docs)
- [nexttick](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/)
- [Event Loop Implementation](https://stackoverflow.com/questions/19822668/what-exactly-is-a-node-js-event-loop-tick)
- [set the event pool size process.env.UV_THREADPOOL_SIZE](http://docs.libuv.org/en/v1.x/threadpool.html)
- [V8 needs 4 threads](https://github.com/nodejs/node/blob/278a9267ec41f37e6b7dda876c417945d7725973/src/node.cc#L3964-L3965)
