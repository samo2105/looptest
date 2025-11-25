module Votes
  class Create
    attr_reader :name, :email, :country_code, :errors

    def initialize(name:, email:, country_code:)
      @name = name
      @email = email&.downcase&.strip
      @country_code = country_code&.upcase
      @errors = []
    end

    def call
      validate_country_code
      if errors.any?
        @vote = nil
        return false
      end

      ActiveRecord::Base.transaction do
        user = find_or_create_user
        vote = create_vote(user)

        if vote.persisted?
          # Check inside transaction to avoid race conditions
          is_new_country = check_if_new_country_inside_transaction(vote)

          enqueue_refresh_job_if_new_country(is_new_country)
          if is_new_country
            Rails.cache.write("country_has_votes:#{country_code}", true, expires_in: 1.hour)
          end
          @vote = vote
          true
        else
          @errors = vote.errors.full_messages
          @vote = nil
          false
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      @vote = nil
      false
    end

    def success?
      return false if @vote.nil?
      @vote.persisted?
    end

    def vote
      @vote
    end

    private

    def validate_country_code
      return if country_code.blank?

      client = Countries::Client.new
      client.fetch_by_code(country_code)
    rescue StandardError => e
      errors << "Invalid country code: #{country_code}"
    end

    def find_or_create_user
      User.find_or_create_by!(email: email) do |u|
        u.name = name
      end
    end

    def create_vote(user)
      Vote.create!(user: user, country_code: country_code)
    rescue ActiveRecord::RecordNotUnique
      vote = Vote.new(user: user, country_code: country_code)
      vote.errors.add(:user_id, "has already been taken")
      vote
    end

    def check_if_new_country_inside_transaction(vote)
      # Database-level check inside transaction to prevent race conditions
      !Vote.where(country_code: country_code).where.not(id: vote.id).exists?
    end

    def enqueue_refresh_job_if_new_country(is_new_country)
      if is_new_country
        Countries::RefreshJob.perform_later([ country_code ])
      end
    end
  end
end
