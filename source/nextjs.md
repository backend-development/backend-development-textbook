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

* static webpages that are rendered once, at build time.
* api endpoints
* server rendered pages that are served as HTML, but can be refreshed.
* React Server Components, where you can mix client and server side components in one react tree

## The missing persistance layer

Next.js is not a full backend framework. For example it does not offer an
ORM or another persistance layer.  There is good documentation for
combining nextjs with

* [superbase](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs), which offers postgres as a service
* [apollo](https://www.apollographql.com/blog/apollo-client/next-js/how-to-use-apollo-client-with-next-js-13/), which offers graphql
* [prisma](https://www.prisma.io/nextjs), a ORM for typescript or javascript


## next.js routing

From `next.js` 13 onwards the routes are created in the `app/` directory.
`page.js` is the default (like index.html used to be), folders can contain parameters in brackets:

```
app/page.js          -->   /
app/otherpage/page.js     -->   /otherpage
app/users/page.js    -->   /users/
app/users/[:id]/page.js   -->   /users/42/
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

## Server Side Rendering (SSR)

With server side rendering, a HTML document is shipped to the browser.
Then the browser loads the necessary JavaScript, and
[hydrates](https://react.dev/reference/react-dom/hydrate#hydrating-server-rendered-html) the HTML
into a client side React App.




## React Server Components

The react render tree is composed from server and client components.  In next.js 13 all components
are server components by default.  You have to add `"use client";` on top of a component to turn
it into a client component.


![](images/react-server-components.png)

### How to use RSC

Simple rules for client and server components:

* Use `.server.js` and `.client.js` as filename extensions.
* Server Components can contain client components.
* Client Components cannot contain server components.
* Server Components can instantiate both client and server components, and pass in a Server Component as the children prop to a ClientComponent.
* Server Components cannot pass functions as props to its descendents, only data.


### Server Components can contain client components:

```js
// this is server_component.server.js
import ClientComponent from './ClientComponent.client'
export default function ServerComponent() {
  return (
    <>
      <ClientComponent />
    </>
  )
}
```

### Client Components cannot contain server components:


```js
// this is client_component.client.js
// ERROR !!!!
import ServerComponent from './ServerComponent.server'
export default function ClientComponent() {
  return (
    <div>
      <ServerComponent />
    </div>
  )
}
```

### You can pass in Server Components to a ClientComponent

```js
// this is outer_server_component.server.js
import ClientComponent from './ClientComponent.client'
import ServerComponent from './ServerComponent.server'
export default function OuterServerComponent() {
  return (
    <ClientComponent>
      <ServerComponent />
    </ClientComponent>
  )
}
```

### Server Comopnents cannot pass functions to its descendents


Because props are serialized into JSON, and functions cannot be serialized into JSON,
Server Components cannot pass functions as props to its descendents.


```js
// ERROR !!!!
function SomeServerComponent() {
  return <button onClick={() => alert('OHHAI')}>Click me!</button>
}
// ERROR !!!!
```


### How RSC Works

its complicated

[RSC Components from Scratch](https://github.com/reactwg/server-components/discussions/5)

[How Server Components Work](https://www.plasmic.app/blog/how-react-server-components-work)


## Hosting next.js

Vercel, the company behind next.js, offers hosting on their platform. There is a free tier.

To host next.js you need:

* to run the build step to create static assets and javascript bundles
* to run node.js on the server

If you are using dokku a node.js buildpack will be chosen by default,
and do both for you. you might additionally consider:

* setting up permanent storage at `public/upload`, if you want to handle uploaded file and store them in the webspcae
* setting up a database



## See Also

- [Next.js Documentation](https://nextjs.org/docs)
- [Next.js Newsletter](https://nextjsweekly.com/)
