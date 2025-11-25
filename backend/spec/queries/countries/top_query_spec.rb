require "rails_helper"

RSpec.describe Countries::TopQuery do
  describe "#call" do
    context "with default limit" do
      it "returns top countries ordered by vote count" do
        create_list(:vote, 5, country_code: "USA")
        create_list(:vote, 3, country_code: "CAN")
        create_list(:vote, 7, country_code: "MEX")
        create_list(:vote, 2, country_code: "BRA")

        Rails.cache.write("country:USA", { name: "United States", region: "Americas" })
        Rails.cache.write("country:CAN", { name: "Canada", region: "Americas" })
        Rails.cache.write("country:MEX", { name: "Mexico", region: "Americas" })
        Rails.cache.write("country:BRA", { name: "Brazil", region: "Americas" })

        query = described_class.new
        results = query.call

        expect(results.length).to eq(4)
        expect(results.first[:country_code]).to eq("MEX")
        expect(results.first[:vote_count]).to eq(7)
        expect(results.second[:country_code]).to eq("USA")
        expect(results.second[:vote_count]).to eq(5)
        expect(results.third[:country_code]).to eq("CAN")
        expect(results.third[:vote_count]).to eq(3)
        expect(results.fourth[:country_code]).to eq("BRA")
        expect(results.fourth[:vote_count]).to eq(2)
      end

      it "includes metadata for each country" do
        create(:vote, country_code: "USA")
        Rails.cache.write("country:USA", {
          name: "United States",
          official: "United States of America",
          capital: "Washington, D.C.",
          region: "Americas",
          subregion: "North America"
        })

        query = described_class.new
        results = query.call

        expect(results.first[:metadata]).to include(
          name: "United States",
          official: "United States of America",
          capital: "Washington, D.C.",
          region: "Americas",
          subregion: "North America"
        )
      end

      it "respects the default limit of 10" do
        15.times do |i|
          create(:vote, country_code: "CODE#{i}")
        end

        query = described_class.new
        results = query.call

        expect(results.length).to eq(10)
      end
    end

    context "with custom limit" do
      it "returns only the specified number of results" do
        create_list(:vote, 5, country_code: "USA")
        create_list(:vote, 3, country_code: "CAN")
        create_list(:vote, 2, country_code: "MEX")

        Rails.cache.write("country:USA", { name: "United States" })
        Rails.cache.write("country:CAN", { name: "Canada" })
        Rails.cache.write("country:MEX", { name: "Mexico" })

        query = described_class.new(limit: 2)
        results = query.call

        expect(results.length).to eq(2)
        expect(results.first[:country_code]).to eq("USA")
        expect(results.second[:country_code]).to eq("CAN")
      end
    end

    context "with search filter" do
      before do
        create_list(:vote, 5, country_code: "USA")
        create_list(:vote, 3, country_code: "CAN")
        create_list(:vote, 2, country_code: "MEX")

        Rails.cache.write("country:USA", {
          name: "United States",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:CAN", {
          name: "Canada",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:MEX", {
          name: "Mexico",
          region: "Americas",
          subregion: "North America"
        })
      end

      it "filters by country name" do
        query = described_class.new(search: "United")
        results = query.call

        expect(results.length).to eq(1)
        expect(results.first[:country_code]).to eq("USA")
      end

      it "filters by region" do
        query = described_class.new(search: "Americas")
        results = query.call

        expect(results.length).to eq(3)
      end

      it "filters by subregion" do
        query = described_class.new(search: "North")
        results = query.call

        expect(results.length).to eq(3)
      end

      it "filters by capital city" do
        # Update cache to include capital cities
        Rails.cache.write("country:USA", {
          name: "United States",
          capital: "Washington, D.C.",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:CAN", {
          name: "Canada",
          capital: "Ottawa",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:MEX", {
          name: "Mexico",
          capital: "Mexico City",
          region: "Americas",
          subregion: "North America"
        })

        query = described_class.new(search: "Washington")
        results = query.call

        expect(results.length).to eq(1)
        expect(results.first[:country_code]).to eq("USA")
      end

      it "filters by capital city case insensitive" do
        # Update cache to include capital cities
        Rails.cache.write("country:USA", {
          name: "United States",
          capital: "Washington, D.C.",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:CAN", {
          name: "Canada",
          capital: "Ottawa",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:MEX", {
          name: "Mexico",
          capital: "Mexico City",
          region: "Americas",
          subregion: "North America"
        })

        query = described_class.new(search: "ottawa")
        results = query.call

        expect(results.length).to eq(1)
        expect(results.first[:country_code]).to eq("CAN")
      end

      it "is case insensitive" do
        query = described_class.new(search: "united")
        results = query.call

        expect(results.length).to eq(1)
        expect(results.first[:country_code]).to eq("USA")
      end

      it "returns empty array when no matches" do
        query = described_class.new(search: "Europe")
        results = query.call

        expect(results).to be_empty
      end
    end

    context "with no votes" do
      it "returns empty array" do
        query = described_class.new
        results = query.call

        expect(results).to be_empty
      end
    end

    context "when metadata is missing" do
      before { Rails.cache.clear }
      it "returns results with nil metadata" do
        create(:vote, country_code: "USA")

        query = described_class.new
        results = query.call

        expect(results.length).to eq(1)
        expect(results.first[:country_code]).to eq("USA")
        expect(results.first[:metadata]).to be_nil
      end
    end

    context "with multiple votes for same country" do
      it "aggregates votes correctly" do
        create_list(:vote, 3, country_code: "USA")
        create_list(:vote, 2, country_code: "USA")

        Rails.cache.write("country:USA", { name: "United States" })

        query = described_class.new
        results = query.call

        expect(results.length).to eq(1)
        expect(results.first[:vote_count]).to eq(5)
      end
    end

    context "with limit edge cases" do
      before do
        create_list(:vote, 5, country_code: "USA")
        create_list(:vote, 3, country_code: "CAN")
        create_list(:vote, 2, country_code: "MEX")

        Rails.cache.write("country:USA", { name: "United States" })
        Rails.cache.write("country:CAN", { name: "Canada" })
        Rails.cache.write("country:MEX", { name: "Mexico" })
      end

      it "handles negative limit by using default" do
        query = described_class.new(limit: -5)
        results = query.call

        # Negative limit should use default (10), but we only have 3 countries
        expect(results.length).to eq(3)
        expect(results).to be_an(Array)
      end

      it "handles zero limit by using default" do
        query = described_class.new(limit: 0)
        results = query.call

        # Zero limit should use default (10), but we only have 3 countries
        expect(results.length).to eq(3)
        expect(results).to be_an(Array)
      end

      it "handles very large limit" do
        query = described_class.new(limit: 1_000_000)
        results = query.call

        expect(results.length).to eq(3)
        expect(results).to be_an(Array)
      end

      it "handles non-integer limit by converting to 0" do
        query = described_class.new(limit: "abc")
        results = query.call

        # "abc".to_i returns 0
        expect(results).to be_an(Array)
      end

      it "handles nil limit by using default" do
        query = described_class.new(limit: nil)
        results = query.call

        # Nil limit should use default (10), but we only have 3 countries
        expect(results.length).to eq(3)
        expect(results).to be_an(Array)
      end
    end

    context "with search edge cases" do
      before do
        create_list(:vote, 5, country_code: "USA")
        create_list(:vote, 3, country_code: "CAN")
        create_list(:vote, 2, country_code: "MEX")

        Rails.cache.write("country:USA", {
          name: "United States",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:CAN", {
          name: "Canada",
          region: "Americas",
          subregion: "North America"
        })
        Rails.cache.write("country:MEX", {
          name: "Mexico",
          region: "Americas",
          subregion: "North America"
        })
      end

      it "handles empty string search" do
        query = described_class.new(search: "")
        results = query.call

        # Empty string should be treated as no search (stripped becomes nil)
        expect(results.length).to eq(3)
      end

      it "handles whitespace-only search" do
        query = described_class.new(search: "   ")
        results = query.call

        # Whitespace should be stripped and treated as no search
        expect(results.length).to eq(3)
      end

      it "handles very long search string" do
        long_search = "a" * 1000
        query = described_class.new(search: long_search)
        results = query.call

        expect(results).to be_empty
      end

      it "handles special characters in search" do
        query = described_class.new(search: "United%States")
        results = query.call

        # Should handle special characters safely
        expect(results).to be_an(Array)
      end

      it "handles SQL injection attempts safely" do
        query = described_class.new(search: "'; DROP TABLE votes; --")
        results = query.call

        # Should not cause errors, just return empty or no matches
        expect(results).to be_an(Array)
      end

      it "handles unicode characters in search" do
        query = described_class.new(search: "México")
        results = query.call

        # Should handle unicode characters
        expect(results).to be_an(Array)
      end

      it "handles search combined with limit" do
        query = described_class.new(search: "America", limit: 2)
        results = query.call

        # Should return top 2 countries matching "America" in region/subregion
        expect(results.length).to be <= 2
        expect(results).to be_an(Array)
      end
    end
  end
end
