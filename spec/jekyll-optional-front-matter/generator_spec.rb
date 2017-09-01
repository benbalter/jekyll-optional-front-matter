describe JekyllOptionalFrontMatter::Generator do
  let(:site) { fixture_site("site") }
  let(:generator) { described_class.new(site) }
  let(:markdown_converter) { generator.send(:markdown_converter) }
  let(:markdown_files) { generator.send(:markdown_files) }
  let(:pages) { generator.send(:pages) }
  let(:pages_to_add) { generator.send(:pages_to_add) }
  let(:static_files_to_remove) { generator.send(:static_files_to_remove) }

  before do
    site.reset
    site.read
  end

  it "grabs the markdown converter" do
    expect(markdown_converter.class).to eql(Jekyll::Converters::Markdown)
  end

  it "grabs the markdown files" do
    expect(markdown_files.count).to eql(3)
    paths = markdown_files.map(&:relative_path)
    expect(paths).to include("/readme.md")
    expect(paths).to include("/file.md")
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
    expect(pages.count).to eql(3)
    names = pages.map(&:name)
    expect(names).to include("readme.md")
    expect(names).to include("file.md")
    expect(names).to include("another-file.markdown")
  end

  it "builds the array of pages to add" do
    expect(pages_to_add.count).to eql(2)
    names = pages_to_add.map(&:name)
    expect(names).to_not include("readme.md")
    expect(names).to include("file.md")
    expect(names).to include("another-file.markdown")
  end

  it "builds the array of static files to remove" do
    expect(static_files_to_remove.count).to eql(2)
    names = pages_to_add.map(&:name)
    expect(names).to_not include("readme.md")
    expect(names).to include("file.md")
    expect(names).to include("another-file.markdown")
  end

  context "generating" do
    before { generator.generate(site) }

    it "adds the pages to the site" do
      expect(site.pages.count).to eql(3)
      names = site.pages.map(&:name)
      expect(names).to_not include("readme.md")
      expect(names).to include("file.md")
      expect(names).to include("another-file.markdown")
      expect(names).to include("index.md")
    end
  end

  context "building" do
    %w(index file another-file).each do |file|
      context "building #{file}.html" do
        before { site.process }

        let(:path) { File.join(site.dest, "#{file}.html") }
        let(:content) { File.read(path) }
        let(:expected_content) do
          "<h1 id=\"#{file}\">#{file.capitalize.tr("-", " ")}</h1>\n"
        end

        it "has a .html extension" do
          expect(path).to be_an_existing_file
        end

        it "renders markdown to HTML" do
          expect(expected_content).to eql(content)
        end
      end
    end
  end

  context "when disabled" do
    let(:site) do
      fixture_site("site", { "optional_front_matter" => { "disabled" => true } })
    end

    context "generating" do
      before { generator.generate(site) }

      it "doesn't add the pages to the site" do
        expect(site.pages.count).to eql(1)
      end
    end
  end

  context "when explicitly enabled" do
    let(:site) do
      fixture_site("site", { "optional_front_matter" => { "disabled" => false } })
    end

    context "generating" do
      before { generator.generate(site) }

      it "does add the pages to the site" do
        expect(site.pages.count).to eql(3)
      end
    end
  end

  context "blacklist" do
    let(:site) { fixture_site("site", { "include" => ["foo.md"] }) }

    %w(
      README.md
      readme.markdown
      LICENSE.mkdn
      licence.md
      COPYING.md
      CODE_OF_CONDUCT.md
      CONTRIBUTING.markdown
      ISSUE_TEMPLATE.md
      PULL_REQUEST_TEMPLATE.md
      vendor/jekyll/README.md
    ).each do |filename|
      it "matches #{filename}" do
        with_page(filename) do |page|
          expect(generator.send(:blacklisted?, page)).to eql(true)
          expect(generator.send(:whitelisted?, page)).to eql(false)
        end
      end
    end

    %w(index.md INDEX.markdown).each do |filename|
      it "doesn't match #{filename}" do
        with_page(filename) do |page|
          expect(generator.send(:blacklisted?, page)).to eql(false)
          expect(generator.send(:whitelisted?, page)).to eql(false)
        end
      end
    end

    context "whitelist" do
      let(:site) { fixture_site("site", { "include" => ["CONTRIBUTING.md"] }) }

      it "whitelists whitelisted files" do
        with_page("CONTRIBUTING.md") do |page|
          expect(generator.send(:blacklisted?, page)).to eql(false)
          expect(generator.send(:whitelisted?, page)).to eql(true)
        end
      end
    end
  end

  context "cleanup" do
    let(:site) do
      fixture_site("site", { "optional_front_matter" => { "remove_originals" => true } })
    end

    context "generating" do
      before { generator.generate(site) }

      it "adds the pages to the site" do
        expect(site.pages.count).to eql(3)
        names = site.pages.map(&:name)
        expect(names).to_not include("readme.md")
        expect(names).to include("file.md")
        expect(names).to include("another-file.markdown")
        expect(names).to include("index.md")
      end

      it "removes the originals" do
        names = site.static_files.map(&:relative_path)
        expect(names).to_not include("/file.md")
        expect(names).to_not include("/another-file.markdown")
        expect(names).to_not include("/index.md")
      end

      it "does not remove blacklisted static files" do
        expect(site.static_files.count).to eql(2)
        names = site.static_files.map(&:relative_path)
        expect(names).to include("/readme.md")
        expect(names).to include("/CONTRIBUTING")
      end
    end
  end

  context "legacy" do
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

        it "does add the pages to the site" do
          expect(site.pages.count).to eql(3)
        end
      end
    end
  end
end
