require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }

    describe "email format" do
      it "validates email format" do
        user = build(:user, email: "invalid-email")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it "accepts valid email format" do
        user = build(:user, email: "valid@example.com")
        expect(user).to be_valid
      end
    end

    describe "email uniqueness" do
      it "validates uniqueness of email (case-insensitive)" do
        create(:user, email: "test@example.com")
        duplicate_user = build(:user, email: "TEST@EXAMPLE.COM")
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to be_present
      end
    end
  end

  describe "email downcasing" do
    it "downcases email before saving" do
      user = create(:user, email: "TEST@EXAMPLE.COM")
      expect(user.email).to eq("test@example.com")
    end

    it "strips whitespace from email" do
      user = create(:user, email: "  test@example.com  ")
      expect(user.email).to eq("test@example.com")
    end
  end
end
