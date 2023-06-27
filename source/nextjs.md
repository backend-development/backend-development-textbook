# Next.js

Next.js is a framework for react
that also includes backend functionality.

After working through this guide you should

- know how to build server rendered pages in next.js
- know how to build api endpoints in next.js


---

## What is next.js?

Next.js is an open source framework, but it is mainly developed by Vercel.
Vercel's business is platform a service. They published next.js in 2016.
React documentation mentions Next.js among "Recommended Toolchains"
since at least 2021.


## What does it offer?

Next.js gives you a folder structure for you application,
and several different ways to render webpages:

* static webpages that are rendered once, at build time.
* api endpoints
* server rendered pages that are served as HTML, but can be refreshed.
* React Server Components, where you can mix client and server side components in one react tree

## The missing persistence layer

Next.js is not a full backend framework. For example it does not offer an
ORM or another persistence layer.  There is good documentation for
combining next.js with

* [superbase](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs), which offers Postgres as a service
* [apollo](https://www.apollographql.com/blog/apollo-client/next-js/how-to-use-apollo-client-with-next-js-13/), which offers GraphQL
* [prisma](https://www.prisma.io/nextjs), a ORM for typescript or javascript


## next.js routing

From next.js 13 onwards the routes are created in the `app/` directory.
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

For static pages we need to set `trailingSlash` to `true` on most webservers.

If the site will be hosted in a subfolder, for example at http://bjelline.pages.mediacube.at/statixnextjs/
we must configure this as the config value `basePath`:

```
const nextConfig = {
  output: 'export',
  trailingSlash: true,
  basePath: '/foldername',
}
```


### using Github or gitlab pages

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
* Use modules to share data in server components, use [context](https://nextjs.org/docs/getting-started/react-essentials#context) to share data in client components.


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


## Telemetry

A next.js app sends at least 500 lines of information to Vercel.
See [Telemetry](https://nextjs.org/telemetry)
to learn what information is sent and how to switch it off.


```
[telemetry] {
  "eventName": "NEXT_CLI_SESSION_STARTED",
  "payload": {
    "nextVersion": "13.4.7",
    "nodeVersion": "v18.16.1",
    "cliCommand": "build",
    "isSrcDir": false,
    "hasNowJson": false,
    "isCustomServer": null,
    "hasNextConfig": true,
    "buildTarget": "default",
    "hasWebpackConfig": false,
    "hasBabelConfig": false,
    "imageEnabled": true,
    "imageFutureEnabled": true,
    "basePathEnabled": false,
    "i18nEnabled": false,
    "locales": null,
    "localeDomainsCount": null,
    "localeDetectionEnabled": null,
    "imageDomainsCount": 0,
    "imageRemotePatternsCount": 0,
    "imageSizes": "16,32,48,64,96,128,256,384",
    "imageLoader": "default",
    "imageFormats": "image/webp",
    "nextConfigOutput": null,
    "trailingSlashEnabled": false,
    "reactStrictMode": false,
    "webpackVersion": 5,
    "turboFlag": false,
    "appDir": true,
    "pagesDir": false
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "build-lint",
    "invocationCount": 1
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "@auth/prisma-adapter",
    "packageVersion": "^1.0.0"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "@prisma/client",
    "packageVersion": "^4.16.1"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "autoprefixer",
    "packageVersion": "10.4.14"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "date-fns",
    "packageVersion": "^2.30.0"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "eslint",
    "packageVersion": "8.43.0"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "eslint-config-next",
    "packageVersion": "13.4.7"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "next",
    "packageVersion": "13.4.7"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "next-auth",
    "packageVersion": "^4.22.1"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "postcss",
    "packageVersion": "8.4.24"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "prisma",
    "packageVersion": "^4.16.1"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "react",
    "packageVersion": "18.2.0"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "react-dom",
    "packageVersion": "18.2.0"
  }
}
[telemetry] {
  "eventName": "NEXT_PACKAGE_DETECTED",
  "payload": {
    "packageName": "tailwindcss",
    "packageVersion": "3.3.2"
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_COMPLETED",
  "payload": {
    "durationInSeconds": 10,
    "totalAppPagesCount": 4,
    "totalPageCount": 0,
    "hasDunderPages": false,
    "hasTestPages": false
  }
}
[telemetry] {
  "eventName": "NEXT_LINT_CHECK_COMPLETED",
  "payload": {
    "durationInSeconds": 0,
    "eslintVersion": "8.43.0",
    "lintedFilesCount": 14,
    "lintFix": false,
    "nextEslintPluginVersion": "13.4.7",
    "nextEslintPluginErrorsCount": 0,
    "nextEslintPluginWarningsCount": 0,
    "nextRulesEnabled": {
      "@next/next/no-html-link-for-pages": "error",
      "@next/next/no-sync-scripts": "error",
      "@next/next/google-font-display": "warn",
      "@next/next/google-font-preconnect": "warn",
      "@next/next/next-script-for-ga": "warn",
      "@next/next/no-before-interactive-script-outside-document": "warn",
      "@next/next/no-css-tags": "warn",
      "@next/next/no-head-element": "warn",
      "@next/next/no-img-element": "warn",
      "@next/next/no-page-custom-font": "warn",
      "@next/next/no-styled-jsx-in-document": "warn",
      "@next/next/no-title-in-document-head": "warn",
      "@next/next/no-typos": "warn",
      "@next/next/no-unwanted-polyfillio": "warn",
      "@next/next/inline-script-id": "error",
      "@next/next/no-assign-module-variable": "error",
      "@next/next/no-document-import-in-page": "error",
      "@next/next/no-duplicate-head": "error",
      "@next/next/no-head-import-in-document": "error",
      "@next/next/no-script-component-in-head": "error"
    },
    "buildLint": true
  }
}
[telemetry] {
  "eventName": "NEXT_TYPE_CHECK_COMPLETED",
  "payload": {
    "durationInSeconds": 0,
    "typescriptVersion": null
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "experimental/optimizeCss",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "experimental/nextScriptWorkers",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "optimizeFonts",
    "invocationCount": 1
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_OPTIMIZED",
  "payload": {
    "durationInSeconds": 13,
    "staticPageCount": 0,
    "staticPropsPageCount": 0,
    "serverPropsPageCount": 0,
    "ssrPageCount": 0,
    "hasStatic404": true,
    "hasReportWebVitals": false,
    "rewritesCount": 0,
    "headersCount": 0,
    "redirectsCount": 0,
    "headersWithHasCount": 0,
    "rewritesWithHasCount": 0,
    "redirectsWithHasCount": 0,
    "middlewareCount": 0,
    "totalAppPagesCount": 4,
    "staticAppPagesCount": 2,
    "serverAppPagesCount": 2,
    "edgeRuntimeAppCount": 0,
    "edgeRuntimePagesCount": 0,
    "totalPageCount": 0,
    "hasDunderPages": false,
    "hasTestPages": false
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcLoader",
    "invocationCount": 1
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcMinify",
    "invocationCount": 1
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcRelay",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcStyledComponents",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcReactRemoveProperties",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcExperimentalDecorators",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcRemoveConsole",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcImportSource",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swcEmotion",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/x86_64-apple-darwin",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/x86_64-unknown-linux-gnu",
    "invocationCount": 1
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/x86_64-pc-windows-msvc",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/i686-pc-windows-msvc",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/aarch64-unknown-linux-gnu",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/armv7-unknown-linux-gnueabihf",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/aarch64-apple-darwin",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/aarch64-linux-android",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/arm-linux-androideabi",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/x86_64-unknown-freebsd",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/x86_64-unknown-linux-musl",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/aarch64-unknown-linux-musl",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "swc/target/aarch64-pc-windows-msvc",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "turbotrace",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "transpilePackages",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "skipMiddlewareUrlNormalize",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "skipTrailingSlashRedirect",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "modularizeImports",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/image",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/future/image",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/legacy/image",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/script",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/dynamic",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "@next/font/google",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "@next/font/local",
    "invocationCount": 0
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/font/google",
    "invocationCount": 1
  }
}
[telemetry] {
  "eventName": "NEXT_BUILD_FEATURE_USAGE",
  "payload": {
    "featureName": "next/font/local",
    "invocationCount": 0
  }
}
```


## See Also

- [Next.js Documentation](https://nextjs.org/docs)
- [Next.js Newsletter](https://nextjsweekly.com/)
