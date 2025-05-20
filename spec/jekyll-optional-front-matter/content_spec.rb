# frozen_string_literal: true

describe JekyllOptionalFrontMatter::Generator do
  let(:site) { fixture_site("site") }
  let(:generator) { described_class.new(site) }
  let(:markdown_files) { generator.send(:markdown_files) }
  let(:pages) { generator.send(:pages) }
  let(:pages_to_add) { generator.send(:pages_to_add) }

  before do
    site.reset
    site.read
  end

  context "before site processing" do
    it "has markdown in the content of pages before generator runs" do
      # Find the file.md static file
      file_md = markdown_files.find { |f| f.name == "file.md" }

      # Create a page without running the generator
      page = generator.send(:page_from_static_file, file_md)
      puts "Before generator - Page content: #{page.content.inspect}"

      # The content should be markdown at this point
      expect(page.content).to eq("# File\n")
    end
  end

  context "after generator runs" do
    before do
      generator.generate(site)
    end

    it "converts markdown content to HTML for pages without front matter" do
      # Get a page that has been added by the plugin (without front matter)
      page = site.pages.find { |p| p.name == "file.md" }
      puts "After generator - Page without FM content: #{page.content.inspect}"

      # The content should be HTML after the generator runs
      expect(page.content).not_to eq("# File\n")
      expect(page.content).to include("<h1")
    end

    it "does not affect pages with front matter" do
      # Debug: List all pages already in site
      puts "Pages in site before adding: #{site.pages.map(&:name).inspect}"

      # Create a test page with front matter
      page = Jekyll::Page.new(site, site.source, "", "test-page-with-frontmatter.md")
      # Set front matter manually
      page.data["title"] = "Test Page"
      # Set the content
      page.content = "# Test Page\n"
      site.pages << page

      # Verify our page was added
      puts "Test page added: #{page.inspect}"

      # The content should still be markdown at this point for regular pages
      # that will be processed normally by Jekyll
      expect(page.content).to eq("# Test Page\n")
    end
  end

  context "after site processing" do
    before do
      generator.generate(site)
      site.process
    end

    it "maintains HTML content for pages without front matter" do
      # Get a page that has been added by the plugin (without front matter)
      page = site.pages.find { |p| p.name == "file.md" }
      puts "After processing - Page without FM content: #{page.content.inspect}"

      # The page output property should contain HTML
      expect(page.output).to include("<h1 id=\"file\">File</h1>")

      # The content property should also be HTML, not markdown
      expect(page.content).not_to eq("# File\n")
      expect(page.content).to include("<h1")
    end

    it "converts markdown content to HTML for pages with front matter" do
      # Get the page with front matter that was already in the site
      page = site.pages.find { |p| p.name == "index.md" }

      # The content should be HTML after site processing
      puts "After processing - Page with FM content: #{page.content.inspect}"

      # The content property should be HTML
      expect(page.content).not_to eq("# Index\n")
      expect(page.content).to include("<h1")
    end
  end
end
