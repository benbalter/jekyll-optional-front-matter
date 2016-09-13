module JekyllOptionalFrontMatter
  class Generator < Jekyll::Generator
    attr_accessor :site

    safe true
    priority :low

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      return if site.config["require_front_matter"]
      site.pages.concat(pages_to_add)
    end

    private

    def pages_to_add
      pages.reject { |page| blacklisted?(page) }
    end

    def pages
      markdown_files.map { |static_file| page_from_static_file(static_file) }
    end

    def markdown_files
      site.static_files.select { |f| markdown_converter.matches(f.extname) }
    end

    def page_from_static_file(static_file)
      base = static_file.instance_variable_get("@base")
      dir  = static_file.instance_variable_get("@dir")
      name = static_file.instance_variable_get("@name")
      Jekyll::Page.new(site, base, dir, name)
    end

    def blacklisted?(page)
      FILENAME_BLACKLIST.include?(page.basename.upcase)
    end

    def markdown_converter
      @markdown_converter ||= site.find_converter_instance(Jekyll::Converters::Markdown)
    end
  end
end
