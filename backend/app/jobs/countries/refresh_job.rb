module Countries
  class RefreshJob < ApplicationJob
    queue_as :default

    def perform(country_codes = nil)
      codes_to_refresh = country_codes || Vote.distinct.pluck(:country_code).compact

      return if codes_to_refresh.empty?

      client = Countries::Client.new

      codes_to_refresh.each do |code|
        begin
          client.fetch_by_code(code)
        rescue StandardError => e
          Rails.logger.error("Failed to refresh country #{code}: #{e.message}")
        end
      end
    end
  end
end
