require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = Rails.root.join('spec', 'fixtures', 'vcr_cassettes')
  c.configure_rspec_metadata!
  c.ignore_hosts '127.0.0.1', 'localhost'
end
