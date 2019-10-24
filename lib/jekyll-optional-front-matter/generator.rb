# frozen_string_literal: true

module JekyllOptionalFrontMatter
  class Generator < Jekyll::Generator
    attr_accessor :site

    safe true
    priority :normal

    CONFIG_KEY = "optional_front_matter"
    ENABLED_KEY = "enabled"
    COLLECTIONS_KEY = "collections"
    CLEANUP_KEY = "remove_originals"

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      return if disabled?

      site.pages.concat(pages_to_add)
      site.static_files -= static_files_to_remove if cleanup?
      collections_to_convert.each_value(&method(:convert_collection)) if collections?
    end

    private

    # An array of Jekyll::Pages to add, *excluding* blacklisted files
    def pages_to_add
      pages.reject { |page| blacklisted?(page) }
    end

    # An array of Jekyll::StaticFile's, *excluding* blacklisted files
    def static_files_to_remove
      markdown_files.reject { |page| blacklisted?(page) }
    end

    # An array of potential Jekyll::Pages to add, *including* blacklisted files
    def pages
      markdown_files.map { |static_file| page_from_static_file(static_file) }
    end

    # An array of Jekyll::StaticFile's with a site-defined markdown extension
    def markdown_files
      site.static_files.select { |file| markdown_converter.matches(file.extname) }
    end

    # Given a Jekyll::StaticFile, returns the file as a Jekyll::Page
    def page_from_static_file(static_file)
      base = static_file.instance_variable_get("@base")
      dir  = static_file.instance_variable_get("@dir")
      name = static_file.instance_variable_get("@name")
      Jekyll::Page.new(site, base, dir, name)
    end

    # Jekyll::Collections to convert Jekyll::StaticFiles to Jekyll::Documents
    def collections_to_convert
      site.collections.reject { |k, _| !Jekyll::CollectionReader::SPECIAL_COLLECTIONS.include?(k) }
    end

    # Given a Jekyll::Collection, read Jekyll::StaticFile as Jekyll::Document
    def convert_collection(collection)
      file_names = collection.files.select {
          |file| markdown_converter.matches(file.extname)
         }.map(&:name)
      full_paths = file_names.map { |e| collection.collection_dir(e) }
      full_paths.each do |full_path|
        next if File.directory?(full_path)

        doc = Jekyll::Document.new(full_path, :site => site, :collection => collection)
        doc.read

        collection.docs << doc if site.unpublished || doc.published?
      end
      collection.docs.sort!
      collection.files.reject! { |file| markdown_converter.matches(file.extname) } if cleanup?
    end

    # Does the given Jekyll::Page match our filename blacklist?
    def blacklisted?(page)
      return false if whitelisted?(page)

      FILENAME_BLACKLIST.include?(page.basename.upcase)
    end

    def whitelisted?(page)
      return false unless site.config["include"].is_a? Array

      entry_filter.included?(page.relative_path)
    end

    def markdown_converter
      @markdown_converter ||= site.find_converter_instance(Jekyll::Converters::Markdown)
    end

    def entry_filter
      @entry_filter ||= Jekyll::EntryFilter.new(site)
    end

    def option(key)
      site.config[CONFIG_KEY] && site.config[CONFIG_KEY][key]
    end

    def disabled?
      option(ENABLED_KEY) == false || site.config["require_front_matter"]
    end

    def collections?
      option(COLLECTIONS_KEY) == true && !site.config["require_front_matter"]
    end

    def cleanup?
      option(CLEANUP_KEY) == true || site.config["require_front_matter"]
    end
  end
end
