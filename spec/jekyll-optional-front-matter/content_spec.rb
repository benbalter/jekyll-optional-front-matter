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
    generator.generate(site)
  end

  context "before site processing" do
    it "has markdown in the content of pages without front matter" do
      # Get a page that has been added by the plugin (without front matter)
      page = site.pages.find { |p| p.name == "file.md" }
      puts "Before processing - Page content: #{page.content.inspect}"
      
      # The content should still be markdown at this point
      expect(page.content).to eq("# File\n")
    end
  end

  context "after site processing" do
    before do
      site.process
    end

    it "converts markdown content to HTML for pages without front matter" do
      # Get a page that has been added by the plugin (without front matter)
      page = site.pages.find { |p| p.name == "file.md" }
      puts "After processing - Page content: #{page.content.inspect}"
      
      # The page output property should contain HTML
      expect(page.output).to include("<h1 id=\"file\">File</h1>")
      
      # The content property should also be HTML, not markdown
      expect(page.content).not_to eq("# File\n")
      expect(page.content).to include("<h1")
    end
    
    it "converts markdown content to HTML for pages with front matter" do
      # Get a page with front matter
      page = site.pages.find { |p| p.name == "index.md" }
      puts "Index page content: #{page.content.inspect}"
      
      # The content property should be HTML
      expect(page.content).not_to eq("# Index\n")
      expect(page.content).to include("<h1")
    end
  end
end