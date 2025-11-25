require "rails_helper"

RSpec.describe Countries::RefreshJob do
  describe "#perform" do
    let(:client) { instance_double(Countries::Client) }
    let(:country_code) { "USA" }

    before do
      allow(Countries::Client).to receive(:new).and_return(client)
      allow(client).to receive(:fetch_by_code).and_return({
        code: country_code,
        name: "United States",
        official: "United States of America",
        capital: "Washington, D.C.",
        region: "Americas",
        subregion: "North America"
      })
    end

    context "when country codes are provided" do
      it "refreshes metadata for specified countries" do
        expect(client).to receive(:fetch_by_code).with("USA")
        expect(client).to receive(:fetch_by_code).with("CAN")

        described_class.new.perform(["USA", "CAN"])
      end
    end

    context "when no country codes are provided" do
      let!(:vote1) { create(:vote, country_code: "USA") }
      let!(:vote2) { create(:vote, country_code: "CAN") }

      it "refreshes metadata for all countries with votes" do
        expect(client).to receive(:fetch_by_code).with("USA")
        expect(client).to receive(:fetch_by_code).with("CAN")

        described_class.new.perform
      end
    end

    context "when API call fails" do
      before do
        allow(client).to receive(:fetch_by_code).and_raise(StandardError.new("API Error"))
      end

      it "logs the error and continues processing" do
        expect(Rails.logger).to receive(:error).at_least(:once)
        
        expect {
          described_class.new.perform(["USA", "CAN"])
        }.not_to raise_error
      end
    end

    context "when there are no votes" do
      it "returns early without making API calls" do
        expect(client).not_to receive(:fetch_by_code)

        described_class.new.perform
      end
    end

    context "with duplicate country codes" do
      let!(:vote1) { create(:vote, country_code: "USA") }
      let!(:vote2) { create(:vote, country_code: "USA") }

      it "only processes each country code once" do
        expect(client).to receive(:fetch_by_code).with("USA").once

        described_class.new.perform
      end
    end

    context "with empty array parameter" do
      it "returns early without making API calls" do
        expect(client).not_to receive(:fetch_by_code)

        described_class.new.perform([])
      end
    end

    context "with invalid country codes in array" do
      before do
        allow(client).to receive(:fetch_by_code).with("USA").and_return({
          code: "USA",
          name: "United States"
        })
        allow(client).to receive(:fetch_by_code).with("INVALID").and_raise(
          StandardError.new("Failed to fetch country: 404")
        )
        allow(client).to receive(:fetch_by_code).with("CAN").and_return({
          code: "CAN",
          name: "Canada"
        })
      end

      it "continues processing other valid codes when one fails" do
        expect(Rails.logger).to receive(:error).at_least(:once)

        expect {
          described_class.new.perform(["USA", "INVALID", "CAN"])
        }.not_to raise_error

        expect(client).to have_received(:fetch_by_code).with("USA")
        expect(client).to have_received(:fetch_by_code).with("INVALID")
        expect(client).to have_received(:fetch_by_code).with("CAN")
      end
    end
  end
end
