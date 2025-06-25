# frozen_string_literal: true

describe "JekyllOptionalFrontMatter Integration" do
  let(:site) { fixture_site("site-with-collections") }
  let(:generator) { JekyllOptionalFrontMatter::Generator.new(site) }

  before do
    site.reset
    site.read
    generator.generate(site)
  end

  it "processes both pages and collection documents" do
    # The site should have the original pages plus any new ones from the generator
    expect(site.pages.length).to be >= 1
    
    # Collections should include documents without front matter
    articles = site.collections["articles"].docs
    expect(articles.length).to be >= 2
    
    # Find the document that was created from a file without front matter
    article_without_fm = articles.find { |doc| doc.basename == "article-without-front-matter.md" }
    expect(article_without_fm).not_to be_nil
    expect(article_without_fm.content).to include("<h1")
    expect(article_without_fm.content).to include("Article Without Front Matter")
  end

  it "handles posts collection correctly" do
    # Posts collection should still work normally since Jekyll processes all posts
    posts = site.collections["posts"].docs
    expect(posts.length).to be >= 2
    
    post_names = posts.map(&:basename)
    expect(post_names).to include("2023-01-01-post-with-front-matter.md")
    expect(post_names).to include("2023-01-02-post-without-front-matter.md")
  end
end