require "swagger_helper"

RSpec.describe "Api::V1::Countries", type: :request do
  path "/api/v1/countries/top" do
    get "Returns top countries by vote count" do
      tags "Countries"
      produces "application/json"
      parameter name: :limit, in: :query, type: :integer, required: false, description: "Number of results to return", example: 10
      parameter name: :search, in: :query, type: :string, required: false, description: "Search term for filtering", example: "United"

      response "200", "top countries returned" do
        before do
          create_list(:vote, 5, country_code: "USA")
          create_list(:vote, 3, country_code: "CAN")
          create_list(:vote, 7, country_code: "MEX")

          Rails.cache.write("country:USA", {
            name: "United States",
            official: "United States of America",
            capital: "Washington, D.C.",
            region: "Americas",
            subregion: "North America"
          })
          Rails.cache.write("country:CAN", {
            name: "Canada",
            official: "Canada",
            capital: "Ottawa",
            region: "Americas",
            subregion: "North America"
          })
          Rails.cache.write("country:MEX", {
            name: "Mexico",
            official: "United Mexican States",
            capital: "Mexico City",
            region: "Americas",
            subregion: "North America"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
          expect(data["countries"].length).to eq(3)
          expect(data["countries"].first["vote_count"]).to eq(7)
          expect(data["countries"].first["country_code"]).to eq("MEX")
        end
      end

      response "200", "with limit parameter" do
        let(:limit) { 2 }

        before do
          create_list(:vote, 5, country_code: "USA")
          create_list(:vote, 3, country_code: "CAN")
          create_list(:vote, 2, country_code: "MEX")

          Rails.cache.write("country:USA", { name: "United States" })
          Rails.cache.write("country:CAN", { name: "Canada" })
          Rails.cache.write("country:MEX", { name: "Mexico" })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["countries"].length).to eq(2)
        end
      end

      response "200", "with search parameter" do
        let(:search) { "United" }

        before do
          create_list(:vote, 5, country_code: "USA")
          create_list(:vote, 3, country_code: "CAN")

          Rails.cache.write("country:USA", {
            name: "United States",
            region: "Americas"
          })
          Rails.cache.write("country:CAN", {
            name: "Canada",
            region: "Americas"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["countries"].length).to eq(1)
          expect(data["countries"].first["country_code"]).to eq("USA")
        end
      end

      response "200", "empty state" do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
          expect(data["countries"]).to be_empty
        end
      end

      response "200", "with negative limit" do
        let(:limit) { -5 }

        before do
          create_list(:vote, 3, country_code: "USA")
          Rails.cache.write("country:USA", { name: "United States" })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
        end
      end

      response "200", "with zero limit" do
        let(:limit) { 0 }

        before do
          create_list(:vote, 3, country_code: "USA")
          Rails.cache.write("country:USA", { name: "United States" })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
        end
      end

      response "200", "with very large limit" do
        let(:limit) { 1_000_000 }

        before do
          create_list(:vote, 3, country_code: "USA")
          Rails.cache.write("country:USA", { name: "United States" })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
        end
      end

      response "200", "with non-integer limit" do
        let(:limit) { "abc" }

        before do
          create_list(:vote, 3, country_code: "USA")
          Rails.cache.write("country:USA", { name: "United States" })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
        end
      end

      response "200", "with search containing special characters" do
        let(:search) { "United%States" }

        before do
          create_list(:vote, 5, country_code: "USA")
          Rails.cache.write("country:USA", {
            name: "United States",
            region: "Americas"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
        end
      end

      response "200", "with both limit and search" do
        let(:limit) { 2 }
        let(:search) { "America" }

        before do
          create_list(:vote, 5, country_code: "USA")
          create_list(:vote, 3, country_code: "CAN")
          create_list(:vote, 2, country_code: "MEX")

          Rails.cache.write("country:USA", {
            name: "United States",
            region: "Americas"
          })
          Rails.cache.write("country:CAN", {
            name: "Canada",
            region: "Americas"
          })
          Rails.cache.write("country:MEX", {
            name: "Mexico",
            region: "Americas"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
          expect(data["countries"].length).to be <= 2
        end
      end
    end
  end

  path "/api/v1/countries" do
    get "Returns list of all countries" do
      tags "Countries"
      produces "application/json"

      response "200", "countries list returned" do
        before do
        Rails.cache.clear
          allow_any_instance_of(Countries::Client).to receive(:fetch_all).and_return([
            {
              code: "USA",
              name: "United States",
              official: "United States of America"
            },
            {
              code: "CAN",
              name: "Canada",
              official: "Canada"
            }
          ])
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("countries")
          expect(data["countries"]).to be_an(Array)
          expect(data["countries"].length).to eq(2)
          expect(data["countries"].first).to have_key("code")
          expect(data["countries"].first).to have_key("name")
        end
      end
    end
  end
end
