require "swagger_helper"

RSpec.describe "Api::V1::Votes", type: :request do
  path "/api/v1/votes" do
    post "Creates a vote" do
      tags "Votes"
      consumes "application/json"
      produces "application/json"
      parameter name: :vote, in: :body, schema: {
        type: :object,
        properties: {
          vote: {
            type: :object,
            properties: {
              name: { type: :string, example: "John Doe" },
              email: { type: :string, example: "john@example.com" },
              country_code: { type: :string, example: "USA" }
            },
            required: ["name", "email", "country_code"]
          }
        }
      }

      response "201", "vote created" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              email: "john@example.com",
              country_code: "USA"
            }
          }
        end

        before do
          allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
            code: "USA",
            name: "United States",
            official: "United States of America"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("vote")
          expect(data).to have_key("user")
          expect(data["vote"]["country_code"]).to eq("USA")
          expect(data["user"]["email"]).to eq("john@example.com")
        end
      end

      response "409", "user has already voted" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              email: "john@example.com",
              country_code: "USA"
            }
          }
        end

        before do
          allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
            code: "USA",
            name: "United States"
          })
          user = create(:user, email: "john@example.com")
          create(:vote, user: user, country_code: "USA")
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("error")
          expect(data["error"]).to include("already voted")
        end
      end

      response "422", "validation error" do
        let(:vote) do
          {
            vote: {
              name: "",
              email: "invalid-email",
              country_code: ""
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
          expect(data["errors"]).to be_an(Array)
        end
      end

      response "422", "invalid country code" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              email: "john@example.com",
              country_code: "INVALID"
            }
          }
        end

        before do
          allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_raise(
            StandardError.new("Failed to fetch country: 404")
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
        end
      end

      response "422", "missing name parameter" do
        let(:vote) do
          {
            vote: {
              email: "john@example.com",
              country_code: "USA"
            }
          }
        end

        before do
          allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
            code: "USA",
            name: "United States"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
          expect(response.status).to eq(422)
        end
      end

      response "422", "missing email parameter" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              country_code: "USA"
            }
          }
        end

        before do
          allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
            code: "USA",
            name: "United States"
          })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
          expect(response.status).to eq(422)
        end
      end

      response "422", "missing country_code parameter" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              email: "john@example.com"
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
          expect(response.status).to eq(422)
        end
      end

      response "422", "empty country code" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              email: "john@example.com",
              country_code: ""
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
        end
      end

      response "422", "whitespace country code" do
        let(:vote) do
          {
            vote: {
              name: "John Doe",
              email: "john@example.com",
              country_code: "   "
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("errors")
        end
      end
    end
  end
end
