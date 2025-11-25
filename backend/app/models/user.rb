class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

  before_validation :normalize_email

  private

  def normalize_email
    return unless email.present?
    self.email = email.downcase.strip
  end
end
