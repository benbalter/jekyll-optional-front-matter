# frozen_string_literal: true

require "jekyll-optional-front-matter"
require "fileutils"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end

Jekyll.logger.adjust_verbosity(:quiet => true)

def fixture_path(fixture)
  File.expand_path "./fixtures/#{fixture}", File.dirname(__FILE__)
end

def fixture_site(fixture, override = {})
  default_config = { "source" => fixture_path(fixture) }
  config = Jekyll::Utils.deep_merge_hashes(default_config, override)
  config = Jekyll.configuration(config)
  Jekyll::Site.new(config)
end

# Create a page, pass it to the block, delete the page
def with_page(path, content: nil, site: nil)
  site ||= fixture_site("tmp")
  base = site.source

  dir = File.dirname(path).sub(%r!^\.$!, "")
  name = File.basename(path)
  full_path = File.join(base, dir, name)

  content ||= "# #{name}"
  FileUtils.mkdir_p File.join(base, dir)
  File.write(full_path, content)

  page = Jekyll::Page.new(site, base, dir, name)
  yield(page)
  File.delete(full_path)
end

RSpec::Matchers.define :be_an_existing_file do
  match { |path| File.exist?(path) }
end
