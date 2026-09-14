# Changelog

## 3.2.1

- Every uniqueness validation now has a unique index behind it, so concurrent writes can't slip a duplicate past the check:
  - `Nation` abbr: unique (the writer upcases, so it is case-insensitive).
  - `City` name: unique on `{nation_id, region_id, name}`, the validation's own scope.
  - `Region` abbr within a nation: partial on `abbr > ""` instead of sparse. Sparse did nothing on a compound index whose `nation_id` is always set, so the second abbr-less region in a nation failed to save.
- The concern no longer declares `{abbr: 1}`. Mongoid keys a declaration on its fields alone, so the concern's copy silently swallowed `Nation`'s unique one. `Region` keeps its own.
- `spec/models/indexes_spec.rb` inserts straight into the collection, past the validations, and expects the index to refuse.

## 3.2.0

- Slugs work in every script: `東京` → `東京`, `Санкт-Петербург` → `санкт-петербург`. Non-Latin names were previously invalid (blank slug). Accents are stripped via NFKD (`Hà Nội` → `ha-noi`). Underscores now become hyphens.
- `Geopolitocracy.slugify(text)` is public; `slug=`, `.search` and `Hood` all use it.
- `Nation['br']` — find by abbr, any case.
- City name uniqueness is now scoped by nation **and** region; region-less cities in different nations no longer collide.
- Removed `==`/`<=>` overrides on City, Region, Hood (Mongoid's `_id` equality already matches the unique indexes) and `Hood#as_json`.
- Removed empty rake task and RDoc task.
- Tested on Ruby 3.2 through 4.0 (CI matrix); `required_ruby_version` is now `>= 3.2` (Rails 8 / the test suite floor).
- Engine request specs cover full CRUD for all four resources.
- `Geopolitical.parent_controller` lets a host app point the engine's controllers at one of its own, so the admin UI inherits the host's authentication. Defaults to `ActionController::Base` (unauthenticated), and the README now says so.
- **i18n**: every label, button, table header and flash in the engine now goes through `I18n`; `config/locales/geopolitical.en.yml` and `geopolitical.pt.yml` ship with the gem. Model and attribute names use Mongoid's `mongoid.models` / `mongoid.attributes` scopes, so `f.label :souls` translates for free.
- The dashboard and layout used `model_name.human.pluralize` for nav headings, which is English-only ("Regiãos"); they now use `model_name.human(count: 2)`.

### Fixes from review


- **City slugs are unique planet-wide again.** A city with no region is now suffixed with its nation abbr (`singapore-sg`, `victoria-sc`), mirroring the region suffix (`santos-sp`). Previously two region-less cities in different nations both slugged to the same string.
- `City`s unique slug index was never created: `Geopolitocracy` declared a plain `index({slug: 1})` that shadowed it. The concern no longer declares one; `Region` (which needs a non-unique one for `.search`) declares its own.
- `slugify` normalizes to NFC first — decomposed input (macOS filenames, some form posts) slugged as `sa-o-paulo`.
- Moving a city to another region now refreshes the cached `rbbr` and rebuilds the slug; it used to keep the old abbr forever.
- Renaming or moving a `Hood` rebuilds its slug instead of stacking prefixes (`rio-rj-santos-sp-gonzaga`).
- `Nation#lang=` keeps the nations other languages instead of wiping `langs` to a single entry.
- `Nation[]` returns `nil` for an unknown abbr instead of raising `DocumentNotFound`.

**Upgrading:** stored slugs are not rewritten until a document is saved again, so existing data is untouched � but region-less cities will pick up a nation suffix the next time they are saved, and `City.create_indexes` will now fail on a database that already holds duplicate city slugs. `geonames_local` depends on `geopolitical > 0.8.4` (no upper bound) and will pick this up on its next bundle.
