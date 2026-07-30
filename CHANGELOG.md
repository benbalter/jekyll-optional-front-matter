# Changelog

## 0.3.3

* Fixed issue where `page.content` contained Markdown text rather than HTML for pages without front matter when applying a template. This was caused by pages without front matter being rendered after all other pages. (#43)
* Maintain the sort order of pages after adding files without front matter (#44)
* Modernize CI (test Ruby 3.3 & 4.0 against Jekyll 3.x & 4.x) and bump rubocop-rspec to `~> 3.0` (#47, #48)
* Enable Dependabot for GitHub Actions; add a CodeQL analysis workflow