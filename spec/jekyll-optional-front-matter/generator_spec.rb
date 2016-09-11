describe JekyllOptionalFrontMatter::Generator do
  let(:site) { fixture_site("site") }
  let(:generator) { described_class.new(site) }
  let(:markdown_converter) { generator.send(:markdown_converter) }
  let(:markdown_files) { generator.send(:markdown_files) }
  let(:pages) { generator.send(:pages) }

  before do
    site.reset
    site.read
  end

  it "grabs the markdown converter" do
    expect(markdown_converter.class).to eql(Jekyll::Converters::Markdown)
  end

  it "grabs the markdown files" do
    expect(markdown_files.count).to eql(2)
    paths = markdown_files.map(&:relative_path)
    expect(paths).to include("/readme.md")
    expect(paths).to include("/another-file.markdown")
  end

  it "builds a page from a static file" do
    static_file = Jekyll::StaticFile.new(site, site.source, "/", "readme.md")
    page = generator.send(:page_from_static_file, static_file)
    expect(page.class).to eql(Jekyll::Page)
    expect(page.name).to eql("readme.md")
    expect(page.content).to eql("# Readme\n")
  end

  it "builds the array of pages" do
    expect(pages.count).to eql(2)
    names = pages.map(&:name)
    expect(names).to include("readme.md")
    expect(names).to include("another-file.markdown")
  end

  context "generating" do
    before { generator.generate(site) }

    it "adds the pages to the site" do
      expect(site.pages.count).to eql(3)
      names = site.pages.map(&:name)
      expect(names).to include("readme.md")
      expect(names).to include("another-file.markdown")
      expect(names).to include("index.md")
    end
  end

  context "when disabled" do
    let(:site) { fixture_site("site", { "require_front_matter" => true }) }
    context "generating" do
      before { generator.generate(site) }

      it "doesn't add the pages to the site" do
        expect(site.pages.count).to eql(1)
      end
    end
  end

  context "when explicitly enabled" do
    let(:site) { fixture_site("site", { "require_front_matter" => false }) }
    context "generating" do
      before { generator.generate(site) }

      it "doesn't add the pages to the site" do
        expect(site.pages.count).to eql(3)
      end
    end
  end
end
