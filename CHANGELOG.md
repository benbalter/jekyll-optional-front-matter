# Changelog

## Unreleased

* Fixed issue where `page.content` contained Markdown text rather than HTML for pages without front matter when applying a template. This was caused by pages without front matter being rendered after all other pages.