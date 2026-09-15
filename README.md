# Geopolitical

[![Gem Version](https://badge.fury.io/rb/geopolitical.svg)](http://badge.fury.io/rb/geopolitical)
[![CI](https://github.com/fireho/geopolitical/actions/workflows/ci.yml/badge.svg)](https://github.com/fireho/geopolitical/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](MIT-LICENSE)

```
        _.--""--._            Nation ─┐  "Brasil"  BR  .br  BRL  +55
      .'   __ o   '.                  │
     /   .'  \      \         Region ─┤  "São Paulo"  SP  America/Sao_Paulo
    |   /  o  |  ~   |                │
    |   \_ o /   ~   |          City ─┤  "São Paulo"  sao-paulo-sp  (-46.63, -23.55)
     \    `-'     ~ /                 │
      '.  ~  ~  ~ .'            Hood ─┘  "Vila Madalena"  sao-paulo-sp-vila-madalena
        `--....--'
                              place.hood.city.region.nation.planet  # => :earth
```

**The whole planet as four Mongoid models.** Nation → Region → City → Hood,
with slugs that never collide, names in every script, geo queries, and a
fallback chain for phone/postal codes. Bring your own data (Geonames, IBGE,
a CSV, a hunch) — or let [geonames_local](https://github.com/nofxx/geonames_local)
fill it for you.

## Why not the other gems?

| gem                                                        | Nation | Region | City | Hood | DB       | Geo | i18n names | Admin UI |
|------------------------------------------------------------|:------:|:------:|:----:|:----:|----------|:---:|:----------:|:--------:|
| [countries](https://github.com/countries/countries)         | ✓      | ✓      | –    | –    | in-memory| –   | ✓          | –        |
| [city-state](https://github.com/loureirorg/city-state)      | ✓      | ✓      | ✓    | –    | in-memory| –   | –          | –        |
| [geonames-rails](https://github.com/tanguyantoine/geonames-rails) | ✓ | ✓  | ✓    | –    | AR       | ✓   | –          | –        |
| [geonames_dump](https://github.com/kmmndr/geonames_dump)    | ✓      | ✓      | ✓    | –    | AR       | ✓   | –          | –        |
| **geopolitical**                                           | ✓      | ✓      | ✓    | ✓    | Mongoid  | ✓   | ✓          | ✓        |

Static lists are great until a user wants *their* city in the dropdown, a
neighborhood on the address, or a query like "cities within 50km".
That's when you want documents, not constants.

## Install

```ruby
gem 'geopolitical'
```

Rails: it's an engine, models autoload. Optionally mount the admin UI:

```ruby
# config/routes.rb
mount Geopolitical::Engine => '/geopolitical'
```

**The admin UI has no authentication of its own** — it is a mountable engine, so
guarding it is the host app's job. Either constrain the mount:

```ruby
authenticate :user, ->(user) { user.admin? } do
  mount Geopolitical::Engine => '/geopolitical'
end
```

or hand the engine a controller of yours that already authenticates:

```ruby
# config/initializers/geopolitical.rb
Geopolitical.parent_controller = 'Admin::BaseController'
```

Plain Ruby: configure Mongoid, then `require 'geopolitical'`.

### Languages

The engine ships `en` and `pt` (`config/locales/geopolitical.*.yml`) and follows
`I18n.locale` — model names, attribute labels, buttons and flashes all move together:

```ruby
I18n.locale = :pt
City.model_name.human(count: 2)      # => "Cidades"
Hood.human_attribute_name(:souls)    # => "População"
```

Override a string by defining the same key in your app, or add a locale by copying
one of those two files. Note the model *data* is localized separately — `name` and
`alt` are `localize: true` fields, so a city carries its own name per language.

## Cheat sheet


```ruby
br = Nation.create!(name: 'Brasil', abbr: 'br', tld: '.br', cash: 'BRL', langs: %w[pt], phone: '55')
sp = Region.create!(name: 'São Paulo', abbr: 'SP', nation: br, timezone: 'America/Sao_Paulo')
sampa = City.create!(name: 'São Paulo', region: sp, souls: 12_000_000, geom: [-46.63, -23.55])
vila = Hood.create!(name: 'Vila Madalena', city: sampa)

Nation['br']                    # => #<Nation BR>   abbr is the _id, any case
Nation.find('BR')               # same thing
sampa.slug                      # => "sao-paulo-sp"    region suffix, no collisions
vila.slug                       # => "sao-paulo-sp-vila-madalena"
sampa.nation                    # => BR   derived from the region, you may omit it
sampa.to_s                      # => "São Paulo/SP"
sampa.with_nation('-')          # => "São Paulo-SP-BR"
sampa.population                # => 12000000   alias of `souls`
vila.phone                      # => "55"   hood → city → region → nation
br.currency                     # => "BRL"  alias of `cash`

City.search('sao pa')           # slug prefix, accent/case-insensitive
City.search('sao-paulo-sp', exact: true)
City.nearby(sampa.geom)         # 2dsphere $near, needs City.create_indexes
City.population.first           # biggest city
Region.ordered                  # by name
```

### Addresses — `Geopolitical::Postal`

Two ways in, one answer out: a `Found` with the street, number, hood, postal
code and the `City` (found, or made under its state's `Region`).

```
  typing "av paulista 1578"  ──suggest──►  [Suggestion(ref, text), …]   free, nothing kept
  the person picks one       ──pick─────►  Found                        one call, yours to store
  a Brazilian CEP            ──find─────►  Found                        free, no key
```

```ruby
# config/initializers/geopolitical.rb
Geopolitical.postal_provider = :google        # :google · :geoapify — nil means no typing search
Geopolitical.postal_key      = ENV['GOOGLE_MAPS_KEY']

token = SecureRandom.uuid                       # one per form: Google bills the typing as one session
Geopolitical::Postal.suggest('av paulista 1578', session: token, nation: 'BR')
# => [#<data Suggestion ref="ChIJ…" text="Avenida Paulista, 1578 - Bela Vista, São Paulo - SP, Brasil">]
found = Geopolitical::Postal.pick('ChIJ…', session: token)
found.street                   # => "Avenida Paulista"
found.number                   # => "1578"
found.city                     # => #<City São Paulo/SP>
found.ref                      # => "ChIJ…"   the provider's id, the one thing Google lets you keep forever

Geopolitical::Postal.find('01311-925')          # a CEP, masked or not — BrasilAPI, whatever the provider
Geopolitical::Postal.find('10001', nation: 'US')  # => nil — no guessing
```

| provider    | data              | store the pick? | free                            |
|-------------|-------------------|-----------------|---------------------------------|
| `:google`   | best, Brazil too  | yes — the address the person picked ([Places policy](https://developers.google.com/maps/documentation/places/web-service/policies)) | typing unlimited in a session, 10k picks/mo |
| `:geoapify` | OpenStreetMap     | yes             | 3,000 requests/day              |
| BrasilAPI   | Correios (CEP)    | yes             | no key, `find` only             |

Google's pick asks the **Essentials** fields and nothing else
(`Postal::Google::FIELDS`) — one field more and it bills as Pro. Suggestions
and picks are never cached; a CEP is cached a day where Rails has a cache.
Offline, unknown, a bad key: `[]` or `nil`, and the form stays open for a
person to type.

Slugs are the API. They're stable, unique, URL-safe and they survive scripts
you can't transliterate:

```
"São Paulo"        => "sao-paulo"
"Baden-Württemberg"=> "baden-wurttemberg"
"Hà Nội"           => "ha-noi"
"St. Louis"        => "st-louis"
"東京"              => "東京"
"Санкт-Петербург"  => "санкт-петербург"
"دبي"              => "دبي"
```

Two Springfields? `springfield-il` and `springfield-ma`. Tokyo with a region
that has no abbr? `tokyo-東京都`. It just works.

## The models

```
Nation   _id = abbr (ISO 3166-1 α2)   gid  tld  cash  code3  langs  capital
  └── Region   abbr (ISO 3166-2)  code  timezone  capital        unique per nation
        └── City   geom (Point)  area  rbbr           slug unique globally
              └── Hood   rank                        slug unique globally
```

Every model shares (via the `Geopolitocracy` concern):
`name` & `alt` (localized), `abbr`, `nick`, `ascii`, `code`, `slug`,
`souls`/`population`, `postal`, `phone`, `.search`, `.ordered`, `to_s`, `==`, `<=>`.

Names get titleized only when you shout or mumble: `'new york'` and
`'NEW YORK'` become `"New York"`; `'McAllen'` stays `"McAllen"`.

## Feeding it

[geonames_local](https://github.com/nofxx/geonames_local) downloads
[Geonames](http://download.geonames.org/export/dump/) dumps and writes
straight into these models:

```
geonames BR -c geonames.yml    # all of Brasil: regions, cities, hoods
```

Or hand-roll from any source — every model is just a Mongoid document.

## Development

```
bundle install
bundle exec rspec     # needs a local mongod

```

Specs take a world tour (`spec/models/world_spec.rb`): Japan, Russia, Greece,
Egypt, India, Korea, Germany, the US, Singapore… add your country if it's
missing, that's the best PR you can send.

## License

MIT. Bug reports and PRs at [fireho/geopolitical](https://github.com/fireho/geopolitical).
