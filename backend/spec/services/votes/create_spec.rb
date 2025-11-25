require "rails_helper"

RSpec.describe Votes::Create do
  let(:name) { "John Doe" }
  let(:email) { "john@example.com" }
  let(:country_code) { "USA" }
  let(:service) { described_class.new(name: name, email: email, country_code: country_code) }

  describe "#call" do
    context "with valid data and new user" do
      it "creates a new user and vote" do
        allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
          code: "USA",
          name: "United States",
          official: "United States of America"
        })

        expect {
          result = service.call
          expect(result).to be true
        }.to change(User, :count).by(1)
          .and change(Vote, :count).by(1)

        expect(service.vote).to be_persisted
        expect(service.vote.user.email).to eq("john@example.com")
        expect(service.vote.country_code).to eq("USA")
      end
    end

    context "when country code already has votes" do
      let!(:existing_vote) { create(:vote, country_code: "USA") }

      it "does not enqueue refresh job for subsequent votes" do
        allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
          code: "USA",
          name: "United States"
        })

        expect(Countries::RefreshJob).not_to receive(:perform_later)
        service.call
      end

      it "still creates the vote successfully" do
        allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
          code: "USA",
          name: "United States"
        })

        expect {
          result = service.call
          expect(result).to be true
        }.to change(Vote, :count).by(1)
      end
    end

    context "with blank country code" do
      let(:country_code) { "" }

      it "returns false and adds error" do
        expect {
          result = service.call
          expect(result).to be false
        }.not_to change(Vote, :count)

        expect(service.errors).to be_present
      end
    end

    context "with country code edge cases" do
      it "handles nil country code" do
        service = described_class.new(name: name, email: email, country_code: nil)

        expect {
          result = service.call
          expect(result).to be false
        }.not_to change(Vote, :count)

        expect(service.errors).to be_present
      end

      it "handles whitespace-only country code" do
        service = described_class.new(name: name, email: email, country_code: "   ")

        expect {
          result = service.call
          expect(result).to be false
        }.not_to change(Vote, :count)

        expect(service.errors).to be_present
      end

      it "handles invalid country code format" do
        allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_raise(
          StandardError.new("Failed to fetch country: 404")
        )

        service = described_class.new(name: name, email: email, country_code: "INVALID123")

        expect {
          result = service.call
          expect(result).to be false
        }.not_to change(Vote, :count)

        expect(service.errors).to be_present
      end
    end

    context "when user exists with different name" do
      let!(:existing_user) { create(:user, email: email, name: "Jane Doe") }

      it "does not update the existing user's name" do
        allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
          code: "USA",
          name: "United States"
        })

        expect {
          result = service.call
          expect(result).to be true
        }.not_to change { existing_user.reload.name }

        expect(existing_user.name).to eq("Jane Doe")
        expect(service.vote.user.name).to eq("Jane Doe")
      end

      it "creates vote for existing user" do
        allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
          code: "USA",
          name: "United States"
        })

        initial_user_count = User.count
        expect {
          result = service.call
          expect(result).to be true
        }.to change(Vote, :count).by(1)

        expect(User.count).to eq(initial_user_count)
        expect(service.vote.user).to eq(existing_user)
      end
    end
  end

  describe "#success?" do
    it "returns true when vote is created" do
      allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_return({
        code: "USA",
        name: "United States"
      })

      service.call
      expect(service.success?).to be true
    end

    it "returns false when vote creation fails" do
      allow_any_instance_of(Countries::Client).to receive(:fetch_by_code).and_raise(
        StandardError.new("Failed to fetch country: 404")
      )

      service.call
      expect(service.success?).to be false
    end
  end
end
