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


## Numbers

There are different Rules for displaying numbers in different languages.
You may be familiar with the European Million being translated into an US Billion.
So different words are used for numbers.

But also the numbers themselves are formatted differently:

```erb
<p><%= number_with_delimiter(100000000) %></p>
````

In many languages this will be displayed as `100.000.000` or `100,000,000`.
Some examples of languages with different number formats are:

* [Indian Numbering System:](https://en.wikipedia.org/wiki/Indian_numbering_system) 10,00,00,000 or 10 lakh.
* [Japanese numerals](https://en.wikipedia.org/wiki/Japanese_numerals#Powers_of_10) 1 0000 0000 or 1億.

Rails provides several helper methods for constructing numbers:

* `number_with_delimiter` - for large numbers like `100.000.000`
* `number_to_currency` - includes the currency like `100.000.000,00 €`
* `number_with_precision` - like `100000000,00`
* `number_to_percentage` - like `90,00 %`
* `number_to_human_size` - for bytes, like `95,4 MB`


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

### Format definitions

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

### Relative Dates

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

In the view you use it like this:

```erb
<p><%=t('orders_in_the_system', count:  @order_items.length) %></p>
```


## Translating Model Names and Attributes

The names of models and their attributes will be used
in many places in the app: from labels for form fields
to error messages in validation.

So it makes sense to store the names of models and their attributes
just once and then reuse them.

In the demo app there are three models: Shirt, Statement and OrderItem.
This is how to specify translations for shirts:

```yml
  activerecord:
    models:
      shirt:
        one: Hemd
        other: Hemden
    attributes:
      shirt:
        sizes:
          one: Größe
          other: Größen
        colors:
          one: Farbe
          other: Farben
```

To refer to a model use `.model_name.human`, for example `Shirt.model_name.human`.
To refer to an attribute use `human_attribute_name`, for example `Shirt.human_attribute_name("colors").
Both methods can take an attribute `count` for pluralization.


## Text stored in tables

The demo app is a shop for shirts with slogans printed on them.
In the first implementation all the slogans are in english.

When we think about selling to different markets we might want
to translate text stored and tables for different purposes:


* translate the shirts names, for example "generic t-shirt" and "fine t-shirt"
* keep the english slogans, but provide translation into several languages to make searching easier
** for example when you search for "freie software" in the app, you should find the slogans related to "free software"
* offer slogans in different languages
** should these be different products with different ids?  or should there be several columns for one product?


### the Mobility gem

The gem Mobility adds translations for table data.
In the demo app Mobility is already installed and configured.

To make the name of a shirt translatable we add the following lines to the model:

```rb
  extend Mobility
  translates :name,  type: :string
```

From now on the gem will enable us to store different names.
For example in the seed file we could do this:

```rb
I18n.locale = :en   # switch to english

s1 = Shirt.create!(
  name: 'Polo Shirt',
  outline: File.read(Rails.root.join('db/seeds/Shirt-type_Polo-omg.svg')),
  colors: '#e0ffcd #fdffcd #ffebbb #ffcab0 white',
  sizes: 'S M L XL XXL'
)

I18n.locale = :de   # switch to german
s1.update(name: 'Polohemd')
```

Now every time the object is read from the database and
the name is retrieved, the locale is used. For example in the rails console
this could look like this:

```
irb(main):001> s1 = Shirt.first
  Shirt Load (1.5ms)  SELECT "shirts".* FROM "shirts" ORDER BY "shirts"."id" ASC LIMIT $1  [["LIMIT", 1]]
=>
#<Shirt:0x00000001271fc570
...
irb(main):002> s1.name
  Mobility::Backends::ActiveRecord::KeyValue::StringTranslation Load (1.3ms)  SELECT "mobility_string_translations".* FROM "mobility_string_translations" WHERE "mobility_string_translations"."translatable_id" = $1 AND "mobility_string_translations"."translatable_type" = $2 AND "mobility_string_translations"."key" = $3  [["translatable_id", 1], ["translatable_type", "Shirt"], ["key", "name"]]
=> "Polo Shirt"
irb(main):003> I18n.locale = :de
=> :de
irb(main):004> s1.name
=> "Polohemd"
```


## Testing

See [Better Tests Through Internationalization ](https://thoughtbot.com/blog/better-tests-through-internationalization)


See Also
--------

* [Rails Guide: Internationalization](https://guides.rubyonrails.org/i18n.html)
* [A Localization Horror Story: It Could Happen To You](https://metacpan.org/pod/distribution/Locale-Maketext/lib/Locale/Maketext/TPJ13.pod#A-Localization-Horror-Story:-It-Could-Happen-To-You)
