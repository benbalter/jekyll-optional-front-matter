# Jekyll Optional Front Matter

A Jekyll plugin to make front matter optional for Markdown files

[![Build Status](https://travis-ci.org/benbalter/jekyll-optional-front-matter.svg?branch=master)](https://travis-ci.org/benbalter/jekyll-optional-front-matter)

## What it does

Out of the box, Jekyll requires that any markdown file have YAML front matter (key/value pairs separated by two sets of three dashes) in order to be processed and converted to HTML.

While that behavior may be helpful for large, complex sites, sometimes it's easier to simply add a plain markdown file and have it render without fanfare.

This plugin does just that. Any Markdown file in your site's source will be treated as a Page and rendered as HTML, even if it doesn't have YAML front matter.

## Usage

1. Add the following to your site's Gemfile:

  ```ruby
  gem 'jekyll-optional-front-matter'
  ```

2. Add the following to your site's config file:

  ```yml
  gems:
    - jekyll-optional-front-matter
  ```

## One potential gotcha

In order to preserve backwards compatability, the plugin does not recognize [a short list of common meta files](https://github.com/benbalter/jekyll-optional-front-matter/blob/master/lib/jekyll-optional-front-matter.rb#L4).

If you want Markdown files like your README, CONTRIBUTING file, CODE_OF_CONDUCT, or LICENSE, etc., you'll need to explicitly add YAML front matter to the file, or add it to your config's list of `include` files, e.g.:

```yml
include:
  - CONTRIBUTING.md
  - README.md
```

## Configuration
You can configure this plugin in `_config.yml` by adding to the `optional_front_matter` key.

### Removing originals

By default the original markdown files will be included as static pages in the output. To remove them from the output, set the `remove_originals` key to `true`:

```yml
optional_front_matter:
  remove_originals: true
```

### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by adding the following to your site's config:

```yml
optional_front_matter:
  enabled: false
```
