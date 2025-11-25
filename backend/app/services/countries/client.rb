module Countries
  class Client
    BASE_URL = ENV.fetch("REST_COUNTRIES_API_URL", "https://restcountries.com/v3.1").freeze
    CACHE_TTL = 24.hours

    def initialize
      @connection = Faraday.new(url: BASE_URL) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end

    def fetch_by_code(country_code)
      cache_key = "country:#{country_code.upcase}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        response = @connection.get("alpha/#{country_code.upcase}")

        if response.status == 200
          # REST Countries API returns an array even for single country
          country_data = response.body.is_a?(Array) ? response.body.first : response.body
          normalize_metadata(country_data)
        else
          raise StandardError, "Failed to fetch country: #{response.status}"
        end
      end
    rescue Faraday::Error => e
      raise StandardError, "Failed to fetch country: #{e.message}"
    end

    def fetch_all
      cache_key = "countries:all"

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        # REST Countries API v3.1 requires fields parameter for /all endpoint
        response = @connection.get("all?fields=cca3,cca2,name,capital,region,subregion")

        if response.status == 200
          response.body.map { |country| normalize_metadata(country) }
        else
          raise StandardError, "Failed to fetch countries: #{response.status}"
        end
      end
    rescue Faraday::Error => e
      raise StandardError, "Failed to fetch countries: #{e.message}"
    end

    private

    def normalize_metadata(country_data)
      {
        code: country_data["cca3"] || country_data["cca2"],
        name: country_data.dig("name", "common"),
        official: country_data.dig("name", "official"),
        capital: country_data["capital"]&.first,
        region: country_data["region"],
        subregion: country_data["subregion"]
      }
    end
  end
end
