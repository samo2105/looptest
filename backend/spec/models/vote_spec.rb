require "rails_helper"

RSpec.describe Vote, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:country_code) }

    describe "user_id uniqueness" do
      it "validates uniqueness of user_id" do
        user = create(:user)
        create(:vote, user: user, country_code: "USA")
        duplicate_vote = build(:vote, user: user, country_code: "CAN")
        expect(duplicate_vote).not_to be_valid
        expect(duplicate_vote.errors[:user_id]).to be_present
      end

      it "allows different users to have votes" do
        user1 = create(:user)
        user2 = create(:user)
        vote1 = create(:vote, user: user1, country_code: "USA")
        vote2 = build(:vote, user: user2, country_code: "USA")
        expect(vote2).to be_valid
      end
    end
  end
end
