require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri]
  }
  # Allow HTTP connections when recording new cassettes
  config.allow_http_connections_when_no_cassette = true
  config.filter_sensitive_data("<REST_COUNTRIES_API_URL>") do
    ENV.fetch("REST_COUNTRIES_API_URL", "https://restcountries.com/v3.1")
  end
end

# Configure WebMock to work with VCR
WebMock.allow_net_connect! if VCR.current_cassette&.recording?
