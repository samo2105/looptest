module Countries
  class TopQuery
    DEFAULT_LIMIT = 10

    def initialize(limit: DEFAULT_LIMIT, search: nil)
      limit_value = limit.nil? ? DEFAULT_LIMIT : limit.to_i
      @limit = limit_value > 0 ? limit_value : DEFAULT_LIMIT
      @search = search&.strip
    end

    def call
      all_votes = Vote.group(:country_code)
                      .select("country_code, COUNT(*) as vote_count")
                      .order("vote_count DESC")

      if @search.present?
        # When searching, we need to check ALL countries before filtering
        votes, metadata_cache = apply_search_filter(all_votes)
      else
        votes = all_votes.limit(@limit)
        metadata_cache = nil
      end

      # Reuse metadata_cache if available (from search), otherwise fetch individually
      votes.map do |vote|
        metadata = if metadata_cache
                    cache_key = "country:#{vote.country_code}"
                    metadata_cache[cache_key]
        else
                    fetch_metadata(vote.country_code)
        end

        {
          country_code: vote.country_code,
          vote_count: vote.vote_count,
          metadata: metadata
        }
      end
    end

    private

    def apply_search_filter(all_votes)
      country_codes = all_votes.map(&:country_code)
      return [ Vote.none, {} ] if country_codes.empty?

      # Batch fetch all metadata using read_multi - more efficient than individual cache reads
      cache_keys = country_codes.map { |code| "country:#{code}" }
      metadata_hash = Rails.cache.read_multi(*cache_keys)

      matching_codes = country_codes.select do |code|
        cache_key = "country:#{code}"
        metadata = metadata_hash[cache_key]
        metadata && matches_search?(metadata)
      end

      # Return top N matching countries and the metadata cache for reuse
      votes = Vote.where(country_code: matching_codes)
                  .group(:country_code)
                  .select("country_code, COUNT(*) as vote_count")
                  .order("vote_count DESC")
                  .limit(@limit)

      [ votes, metadata_hash ]
    end

    def matches_search?(metadata)
      return false unless metadata

      search_term = @search.downcase
      metadata[:name]&.downcase&.include?(search_term) ||
        metadata[:capital]&.downcase&.include?(search_term) ||
        metadata[:region]&.downcase&.include?(search_term) ||
        metadata[:subregion]&.downcase&.include?(search_term)
    end

    def fetch_metadata(country_code)
      return nil if country_code.blank?

      cache_key = "country:#{country_code}"
      Rails.cache.read(cache_key)
    rescue StandardError
      nil
    end
  end
end
