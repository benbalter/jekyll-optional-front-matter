# frozen_string_literal: true

describe "JekyllOptionalFrontMatter with Collections" do
  let(:site) { fixture_site("site-with-collections") }
  let(:generator) { JekyllOptionalFrontMatter::Generator.new(site) }

  before do
    site.reset
    site.read
  end

  context "before generator runs" do
    it "has collections defined" do
      # Verify collections exist
      expect(site.collections.keys).to include("posts", "articles")
    end

    it "posts collection processes all markdown files (Jekyll default behavior)" do
      # Check posts collection - Jekyll processes all files in _posts even without front matter
      posts = site.collections["posts"].docs
      puts "Posts found: #{posts.length}"
      posts.each { |p| puts "  - #{p.basename}" }
      
      expect(posts.length).to be >= 2
      
      post_names = posts.map(&:basename)
      expect(post_names).to include("2023-01-01-post-with-front-matter.md")
      expect(post_names).to include("2023-01-02-post-without-front-matter.md")
    end

    it "custom collections only process files with front matter" do      
      # Check articles collection - custom collections need front matter
      articles = site.collections["articles"].docs
      puts "Articles found: #{articles.length}"
      articles.each { |a| puts "  - #{a.basename}" }
      
      expect(articles.length).to be >= 1
      
      article_names = articles.map(&:basename)
      expect(article_names).to include("article-with-front-matter.md")
      expect(article_names).not_to include("article-without-front-matter.md")
    end

    it "custom collection files without front matter become static files" do
      # Let's see if they're in static files instead
      static_files = site.static_files
      puts "Static files found: #{static_files.length}"
      static_files.each { |f| puts "  - #{f.relative_path}" }
      
      static_paths = static_files.map(&:relative_path)
      expect(static_paths).to include("_articles/article-without-front-matter.md")
    end
  end

  context "after generator runs" do
    before { generator.generate(site) }

    it "processes collection documents without front matter" do
      # After running the generator, custom collections should now include
      # documents that were previously only static files
      articles = site.collections["articles"].docs
      puts "Articles after generator: #{articles.length}"
      articles.each { |a| puts "  - #{a.basename}" }
      
      expect(articles.length).to be >= 2
      
      article_names = articles.map(&:basename)
      expect(article_names).to include("article-with-front-matter.md")
      expect(article_names).to include("article-without-front-matter.md")
    end

    it "removes static files that became collection documents" do
      # The static file should no longer exist
      static_files = site.static_files
      static_paths = static_files.map(&:relative_path)
      expect(static_paths).not_to include("_articles/article-without-front-matter.md")
    end
  end
end