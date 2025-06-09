# Geopolitical Gem

[![Gem Version](https://badge.fury.io/rb/geopolitical.svg)](http://badge.fury.io/rb/geopolitical)
[![Code Climate](https://codeclimate.com/github/fireho/geopolitical.svg)](https://codeclimate.com/github/fireho/geopolitical)
[![Dependency Status](https://gemnasium.com/fireho/geopolitical.svg)](https://gemnasium.com/fireho/geopolitical)

The `geopolitical` gem provides a set of Mongoid models for representing geopolitical entities: `Nation`, `Region`, `City`, and `Hood` (neighborhood). It aims to offer a ready-to-use solution for applications needing to manage and query geographical data.

## Features

- **Hierarchical Models:** Clear parent-child relationships:
  - `Nation` (Country)
  - `Region` (State/Province, belongs to a Nation)
  - `City` (District/Microregion, belongs to a Nation and optionally a Region)
  - `Hood` (Zone/Neighborhood, belongs to a City)
- **Rich Attributes:**
  - Localized names (`name`, `alt`) and ASCII versions (`ascii`).
  - Common abbreviations (`abbr`) and nicknames (`nick`).
  - Population data (`souls`, aliased as `population`).
  - Standardized codes (e.g., ISO 3166-1 for Nations, ISO 3166-2 for Regions).
  - Top-level domains (`tld`), currency (`cash`), and languages (`langs`) for Nations.
  - Timezones for Regions.
  - Geospatial data (`geom` for City coordinates, `area`).
  - Contact information like postal codes (`postal`) and phone dialing codes (`phone`), with fallbacks to parent entities.
- **`Geopolitocracy` Concern:** A shared Mongoid concern (`app/models/concerns/geopolitocracy.rb`) providing common fields (name, abbr, slug, souls, ascii, code, postal, phone), validations, slug generation, and basic search functionality to all geopolitical models.
- **Slug Generation:** Automatic, URL-friendly slug generation for all entities. Slugs are unique globally for Nations, Cities (due to region/nation context in slug), and Hoods (due to city context in slug), and unique within their parent nation for Regions.
- **Internationalization (i18n):** Support for localized names.
- **Data Population:** Designed to be populated using data from sources like Geonames, particularly via the [geonames_local gem](https://github.com/fireho/geonames_local).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "geopolitical"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install geopolitical
```

## Usage

Once the gem is installed and your MongoDB connection is configured, you can use the models like any other Mongoid document.

```ruby
# Example: Creating a Nation
brasil = Nation.create(name: "Brasil", abbr: "BR", tld: ".br", cash: "BRL", langs: ["pt"])

# Example: Creating a Region within that Nation
sao_paulo_state = Region.create(name: "São Paulo State", abbr: "SP", nation: brasil)

# Example: Creating a City within that Region
sao_paulo_city = City.create(name: "São Paulo", region: sao_paulo_state, nation: brasil, souls: 12_000_000)
# City slug will be something like 'sao-paulo-sp'

# Example: Creating a Hood within that City
vila_madalena = Hood.create(name: "Vila Madalena", city: sao_paulo_city)
# Hood slug will be something like 'sao-paulo-sp-vila-madalena'

# Accessing hierarchical data
puts vila_madalena.city.name # => "São Paulo"
puts vila_madalena.city.region.name # => "São Paulo State"
puts vila_madalena.city.nation.abbr # => "BR"

# Using fallbacks for phone/postal codes
# If hood_phone is nil, it will try city.phone, then city.region.phone, etc.
puts vila_madalena.phone
```

### Using Outside Rails

If you're using the gem in a non-Rails Ruby project, you might need to require the models explicitly after setting up Mongoid:

```ruby
require 'mongoid'
# Configure Mongoid connection here
# Mongoid.load!("path/to/mongoid.yml", :environment)

require 'geopolitical' # Or more specifically 'geopolitical/models' if needed
```

## Models Overview

### `Nation`

Represents a country.

- Key fields: `name`, `abbr` (used as `_id`), `slug`, `gid` (Geonames ID), `tld`, `cash`, `code3` (ISO 3166-1 alpha-3), `langs`.
- Associations: `has_many :regions`, `has_many :cities`, `belongs_to :capital` (a City).

### `Region`

Represents a state, province, or administrative division within a Nation.

- Key fields: `name`, `abbr`, `slug`, `timezone`.
- Associations: `belongs_to :nation`, `has_many :cities`, `belongs_to :capital` (a City).
- Slug uniqueness is scoped to its `nation_id`.

### `City`

Represents a city, town, or significant populated place.

- Key fields: `name`, `slug`, `area`, `geom` (Point for coordinates).
- Associations: `belongs_to :nation`, `belongs_to :region` (optional), `has_many :hoods`.
- Slug includes region context for uniqueness (e.g., `cityname-regionabbr`).

### `Hood`

Represents a neighborhood or sub-locality within a City.

- Key fields: `name`, `slug`, `rank`.
- Associations: `belongs_to :city`.
- Slug includes city context for uniqueness (e.g., `cityslug-hoodname`).

## WHY THIS GEM EXISTS

So you can do this:

    place.hood.city.region.nation.planet # => :earth

That actually works, but works better with:

## Data Population

It is highly recommended to use the [geonames_local gem](https://github.com/fireho/geonames_local) to populate the database with data from [Geonames.org](http://download.geonames.org/export/dump/). This gem provides tools and Rake tasks to download and import Geonames data into the `geopolitical` model structure.

Refer to the `geonames_local` documentation for detailed instructions on populating your database.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/fireho/geopolitical](https://github.com/fireho/geopolitical). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
