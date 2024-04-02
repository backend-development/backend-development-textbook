Internationalization
=======================

This guide will give you an overview
of the problems you face when writing an app
that's used in many countries, in many languages.
After reading it you should be familiar with:

* the concepts of Internationalization and Localisation
* the Rails I18n gem
* how Rails handles some of the most important topics
  * handling dates
  * handling numbers and plurals

You can use the [Demo App](https://gitlab.mediacube.at/bjelline/statement_shirts) to try out the concepts step by step.

---------------------------------------------------------------------------

## Internationalization and Localization

Internationalization is the process of designing a software application so that it can be adapted to various languages and regions. It is often written as I18n (to avoid typing 18 letters).

Localization is the process of adapting internationalized software for a specific region or language by translating text and adding locale-specific components. It is often written as L10n (to avoid typing 10 letters).

Localization (which is potentially performed multiple times, for different locales) uses the infrastructure or flexibility provided by internationalization (which is ideally performed only once before localization, or as an integral part of ongoing development).

## The big picture

When developing web applications for different countries, cultures, languages
we are faced with many different problems:

* Different cultures will have very different ideas of what a "good" website looks like. See [Jenny Shen's talk at concat](https://www.youtube.com/watch?v=ER3534JJucc)
* Different writing systems will use a diffrent amount of space, leading to diffrent layouts
* Writing direction (left-to-right, right-to-left or top-down) will need to be handled by HTML. See [w3c](https://www.w3.org/International/questions/qa-html-dir)
* The app might need to handle different currencies and methods of payment


## Focus on Language

Internationalization is mostly concerned with language and translation.
Even if we focus on indo-european languages we will find differences:

* Example: Plurals  in Polish [Polnisch für Anfänger by stach_mat, Teil 5](https://www.tiktok.com/@stach_mat/video/7325101589084130592)

Going from a mono-lingual to a multi-lingual app will
add another layer of abstraction that will make both programming
and testing harder.

## I18n in Rails

Rails Apps are ready for Internationalization. To get started,
find the file `config/locale/en.yml`.  It only contains one example
of a translation string:


```yml
en:
  hello: "Hello world"
```

This means, that in the `:en` locale, the key `hello` will map to the `Hello world` string

The [Demo App](https://gitlab.mediacube.at/bjelline/statement_shirts) is already
prepared to switch between locales through folders:

* http://localhost:3000/ - Home page and order page - english
* http://localhost:3000/de/ - Home page and order page - german
* http://localhost:3000/dk/ - Home page and order page - danish
* http://localhost:3000/es/ - Home page and order page - spanish
* http://localhost:3000/shirts - List of all shirts - english
* http://localhost:3000/de/shirts - List of all shirts - english
* http://localhost:3000/dk/shirts - List of all shirts - danish
* http://localhost:3000/en/shirts - List of all shirts - spanish

and so on.


## keys and translations

The method `I18n.translate` or `I18n.t` can be used to look up translation.
In our example before the key was `hello`. In english `t 'hello'` will return "Hello World"
and in German it would be "Hallo Welt".

In the view we can use the even short form:

```erb
<%= t 'hello' %>
```

If no translation can be found - because there is no yaml file or because
the key is missing, then a span with class `translation_missing` will be wrapped
around the text.  The key itself will be used in place of a translation:

```html
<span class="translation_missing" title="translation missing: dk.hello">Hello</span>
```

Texts in views all need to be replaced by translation keys.


## locale files included with the I18n gem

The I18n gem comes with translations for many languages in the  [locale folder](https://github.com/svenfuchs/rails-i18n/tree/10141c451f03d7c6b78cfdcce808c389da6b9ddd/rails/locale).

You can copy the ones you need to your own apps `config/locale` folder
to use them.

If you are following along with the demo app, do this now for english, german, danish and spanish!

## Dates

Dates are a special case for translation: there are complex and different rules
for displaying dates in different languages.


The page `/order_items` gives a list of all orders, with a timestamp when each order was placed:

```erb
  <p>
    <strong>Order Date:</strong>
    <%= order_item.created_at %>
  </p>
```

We can use the method `I18n.localize` or `I18n.l` in the view to
display this in a language appropriate format:

```erb
  <p>
    <strong>Order Date:</strong>
    <%=l order_item.created_at %>
  </p>
```

In German this will be displayed as:

```html
  <p>
    <strong>Order Date:</strong>
    Montag, 01. April 2024, 21:25 Uhr
  </p>
```

You can find the definition for this date in `de.yml` under `de.time.formats.default`:

```yml
  time:
    formats:
      default: "%A, %d. %B %Y, %H:%M Uhr"
      long: "%A, %d. %B %Y, %H:%M Uhr"
      short: "%d. %b, %H:%M Uhr"
```

To choose another format, you can add call `l` with the format option:

```erb
  <p>
    <strong>Order Date:</strong>
    <%=l order_item.created_at, format: :short %>
  </p>
```

Different languages will have different format, here a comparison of `:short`:

```yml
en:
  short: "%d %b %H:%M"
es:
  short: "%-d de %b %H:%M"
da:
  short: "%e. %b %Y, %H.%M"
de:
  short: "%d. %b, %H:%M Uhr"
```

As you can see, it is not only the names of weekdays and months that are
translated, but also the whole format changes from language to language.

You could add other formats than ':long' and ':short'  to your translations
by adding to the `.yml` files.  Just make sure to keep the keys consistent through all languages!

## Relative Dates

The helper `time_ago_in_words` is already localized, you
can use it directly:

```erb
  <p>
    <strong>Order Date:</strong>
    <%= time_ago_in_words order_item.created_at %>
  </p>
```

## Pluralization

The page `/order_items` gives a list of all orders, and also the number of orders.
Before internationalization this looked like this:

```erb
<p>There are <%= @order_items.length %> orders in the system.</p>
```

When translating this we also have to think about pluralization rules.
English is simple: just add an 's' to the end of the noun for more then one order.
Other languages follow more complex rules.

You can see how the example from polish in the video above is handled in the
standard translation for dates:

* Rails Pluralisation Rules for Polish [pluralization/pl.rb](https://github.com/svenfuchs/rails-i18n/blob/master/rails/pluralization/pl.rb)
* Use in [locale/pl.rb](https://github.com/svenfuchs/rails-i18n/blob/10141c451f03d7c6b78cfdcce808c389da6b9ddd/rails/locale/pl.yml#L63)


To build our own pluralisation rules we can add translations with several cases.
How many cases there are, and what they are called, differs from language
to language.  Make sure to look it up in [pluralization/*](https://github.com/svenfuchs/rails-i18n/blob/master/rails/pluralization/)

```yml
  orders_in_the_system:
    zero: Es gibt keine Bestellungen im System
    one: Es gibt eine Bestellung im System
    other: Es gibt %{count} Bestellungen im System
```


## Translating Model Names and Attributes

The names of models and their attributes will be used
in many places in the app: from labels for form fields
to error messages in validation.

So it makes sense to store the names of models and their attributes
just once and then reuse them.

In the demo app there are


See Also
--------

* [Rails Guide: Internationalization](https://guides.rubyonrails.org/i18n.html)
* [A Localization Horror Story: It Could Happen To You](https://metacpan.org/pod/distribution/Locale-Maketext/lib/Locale/Maketext/TPJ13.pod#A-Localization-Horror-Story:-It-Could-Happen-To-You)
