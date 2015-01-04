Geopolitical
============

[![Code Climate](https://codeclimate.com/github/fireho/geopolitical.png)](https://codeclimate.com/github/fireho/geopolitical)
[![Build Status](https://travis-ci.org/fireho/geopolitical.png)](https://travis-ci.org/fireho/geopolitical)

Geopolitical models ready to use!

With
----

    gem "geopolitical"


I have
------

Nation > Region > City > Hood all with:

* Names (with i18n and sanitized version)
* ISO codes and abbreviations (Nations & Regions)
* Hierarchy (Hood.first.city.region.nation.abbr # BR)
* Languages
* Geometries
* Postal codes
* Phone codes


Geopolitical
------------

## ISO 3366-1

Two letter code: BR, DE, UK, US...

## ISO 3366-2

Region/Province state code:
BR-SP, BR-RJ, BR-MG, US-NY, US-WA, US-CA

## Geometries

Areas and points.


## Phone codes

With the help of phonie, it's now easy to two way
map entities and phone codes.

## Postal codes

Great for address validation and form pre-population.


Outside Rails
-------------

    require 'geopolitical/models'


Naming
------

* Nation ->  Country
  * Region ->  State/Province
    * City   ->  District/Microregion
      * Hood   ->  Zone/Neighbourhood


Each must be inside the former.


Populate
--------

Use Geonames_local to populate data easily!
"geonames_local"(https://github.com/fireho/geonames_local)


This project rocks and uses MIT-LICENSE.
