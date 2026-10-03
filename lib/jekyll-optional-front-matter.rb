# frozen_string_literal: true

require "jekyll"
require "jekyll-optional-front-matter/generator"

module JekyllOptionalFrontMatter
  # Case-insensitive array of filenames to exclude. All files must first
  # match the config-defined list of markdown extensions. If you'd like one
  # of these files included in your site, simply add YAML front matter to it.
  FILENAME_DENYLIST = %w(
    README
    LICENSE
    LICENCE
    COPYING
    CODE_OF_CONDUCT
    CONTRIBUTING
    ISSUE_TEMPLATE
    PULL_REQUEST_TEMPLATE
  ).freeze

  # Deprecated: use FILENAME_DENYLIST. Kept so existing callers don't break.
  FILENAME_BLACKLIST = FILENAME_DENYLIST
  deprecate_constant :FILENAME_BLACKLIST
end
