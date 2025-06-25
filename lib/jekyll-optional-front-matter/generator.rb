# frozen_string_literal: true

module JekyllOptionalFrontMatter
  class Generator < Jekyll::Generator
    attr_accessor :site

    safe true
    priority :normal

    CONFIG_KEY = "optional_front_matter"
    ENABLED_KEY = "enabled"
    CLEANUP_KEY = "remove_originals"

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      return if disabled?

      # Add pages to the site
      pages_to_add.each do |page|
        # Pre-convert the content of pages without front matter to ensure
        # page.content contains HTML instead of Markdown
        convert_content(page)
        site.pages << page
      end

      # Add collection documents to the site
      collection_documents_to_add.each do |collection_name, documents|
        documents.each do |document|
          # Pre-convert the content of documents without front matter 
          convert_document_content(document)
          site.collections[collection_name].docs << document
        end
      end

      site.static_files -= static_files_to_remove if cleanup?
    end

    private

    # Convert markdown content to HTML for the page
    def convert_content(page)
      renderer = Jekyll::Renderer.new(site, page)
      page.content = renderer.convert(page.content)
    end

    # Convert markdown content to HTML for collection documents
    def convert_document_content(document)
      renderer = Jekyll::Renderer.new(site, document)
      document.content = renderer.convert(document.content)
    end

    # An array of Jekyll::Pages to add, *excluding* blacklisted files
    def pages_to_add
      pages.reject { |page| blacklisted?(page) }
    end

    # An array of Jekyll::StaticFile's, *excluding* blacklisted files
    def static_files_to_remove
      files_to_remove = markdown_files.reject { |file| blacklisted?(page_from_static_file(file)) }
      files_to_remove += collection_static_files.reject { |file| blacklisted?(document_from_static_file(file)) }
      files_to_remove
    end

    # A hash of collection names to Jekyll::Documents to add
    def collection_documents_to_add
      collection_static_files.group_by { |file| collection_name_from_path(file.relative_path) }
                             .transform_values { |files| files.map { |file| document_from_static_file(file) }
                                                             .reject { |doc| blacklisted?(doc) } }
    end

    # An array of Jekyll::StaticFile's in collection directories with markdown extensions
    def collection_static_files
      site.static_files.select do |file|
        file.relative_path.start_with?('_') && 
        file.relative_path.include?('/') &&
        markdown_converter.matches(file.extname) &&
        collection_name_from_path(file.relative_path) &&
        site.collections.key?(collection_name_from_path(file.relative_path))
      end
    end

    # Extract collection name from file path (e.g., "_articles/file.md" -> "articles")
    def collection_name_from_path(path)
      parts = path.split('/')
      return nil unless parts.first&.start_with?('_')
      parts.first[1..-1] # Remove the leading underscore
    end

    # Given a Jekyll::StaticFile in a collection directory, returns it as a Jekyll::Document
    def document_from_static_file(static_file)
      collection_name = collection_name_from_path(static_file.relative_path)
      collection = site.collections[collection_name]
      
      # Get file path relative to the site source
      path = static_file.path
      
      # Create a document similar to how Jekyll::Collection#read does it
      document = Jekyll::Document.new(path, { 
        site: site, 
        collection: collection 
      })
      
      # Read the document content from file
      document.read
      
      document
    end

    # An array of Jekyll::StaticFile's with a site-defined markdown extension (excluding collection files)
    def markdown_files
      site.static_files.select do |file| 
        markdown_converter.matches(file.extname) && 
        !file.relative_path.start_with?('_')
      end
    end

    # An array of potential Jekyll::Pages to add, *including* blacklisted files
    def pages
      markdown_files.map { |static_file| page_from_static_file(static_file) }
    end

    # Given a Jekyll::StaticFile, returns the file as a Jekyll::Page
    def page_from_static_file(static_file)
      base = static_file.instance_variable_get(:@base)
      dir  = static_file.instance_variable_get(:@dir)
      name = static_file.instance_variable_get(:@name)
      Jekyll::Page.new(site, base, dir, name)
    end

    # Does the given Jekyll::Page or Jekyll::Document match our filename blacklist?
    def blacklisted?(page_or_doc)
      return false if whitelisted?(page_or_doc)

      basename = if page_or_doc.respond_to?(:basename)
                   page_or_doc.basename
                 elsif page_or_doc.respond_to?(:name)
                   File.basename(page_or_doc.name, File.extname(page_or_doc.name))
                 else
                   File.basename(page_or_doc.path, File.extname(page_or_doc.path))
                 end

      FILENAME_BLACKLIST.include?(basename.upcase)
    end

    def whitelisted?(page_or_doc)
      return false unless site.config["include"].is_a? Array

      relative_path = if page_or_doc.respond_to?(:relative_path)
                        page_or_doc.relative_path
                      elsif page_or_doc.respond_to?(:path)
                        Pathname.new(page_or_doc.path).relative_path_from(Pathname.new(site.source)).to_s
                      else
                        return false
                      end

      entry_filter.included?(relative_path)
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

    def cleanup?
      option(CLEANUP_KEY) == true || site.config["require_front_matter"]
    end
  end
end
