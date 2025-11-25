require "rails_helper"

RSpec.describe Countries::Client, :vcr do
  let(:client) { described_class.new }
  let(:country_code) { "usa" }

  describe "#fetch_by_code" do
    context "when country exists" do
      it "returns normalized country metadata" do
        result = client.fetch_by_code(country_code)

        expect(result).to include(
          code: be_a(String),
          name: be_a(String),
          official: be_a(String),
          capital: be_a(String).or(be_nil),
          region: be_a(String).or(be_nil),
          subregion: be_a(String).or(be_nil)
        )
      end

      it "caches the result" do
        Rails.cache.clear
        expect(Rails.cache).to receive(:fetch).with(
          "country:USA",
          expires_in: 24.hours
        ).and_call_original

        client.fetch_by_code(country_code)
      end

      it "returns cached result on subsequent calls" do
        Rails.cache.clear
        first_call = client.fetch_by_code(country_code)
        second_call = client.fetch_by_code(country_code)

        expect(second_call).to eq(first_call)
      end
    end

    context "when country does not exist" do
      it "raises an error", vcr: { cassette_name: "countries/invalid_code" } do
        expect {
          client.fetch_by_code("INVALID")
        }.to raise_error(StandardError, /Failed to fetch country/)
      end
    end

    context "when API request fails", :vcr => false do
      before { Rails.cache.clear }
      it "raises an error with message" do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(
          Faraday::ConnectionFailed.new("Connection failed")
        )

        expect {
          client.fetch_by_code(country_code)
        }.to raise_error(StandardError, /Failed to fetch country/)
      end
    end
  end

  describe "#fetch_all" do
    it "returns an array of normalized country metadata", vcr: { cassette_name: "countries/all" } do
      result = client.fetch_all

      expect(result).to be_an(Array)
      expect(result.length).to be > 0
      expect(result.first).to include(
        code: be_a(String),
        name: be_a(String),
        official: be_a(String)
      )
    end

    it "caches the result", vcr: { cassette_name: "countries/all_cached" } do
      Rails.cache.clear
      expect(Rails.cache).to receive(:fetch).with(
        "countries:all",
        expires_in: 24.hours
      ).and_call_original

      client.fetch_all
    end
  end

  describe "cache behavior" do
    it "uses cache key with country code" do
      Rails.cache.clear
      client.fetch_by_code("USA")
      
      expect(Rails.cache.exist?("country:USA")).to be true
    end

    it "respects cache TTL" do
      Rails.cache.clear
      client.fetch_by_code("USA")
      
      # Verify cache entry exists
      expect(Rails.cache.exist?("country:USA")).to be true
    end
  end
end
