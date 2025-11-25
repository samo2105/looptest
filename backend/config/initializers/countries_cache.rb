# Pre-populate country metadata cache on application startup
Rails.application.config.after_initialize do
  next if Rails.env.test?

  begin
    ActiveRecord::Base.connection_pool.with_connection do
      country_codes = Vote.distinct.pluck(:country_code).compact

      if country_codes.any?
        Rails.logger.info("Pre-populating cache for #{country_codes.length} countries with votes...")

        client = Countries::Client.new
        success_count = 0
        error_count = 0

        country_codes.each do |code|
          begin
            client.fetch_by_code(code)
            success_count += 1
          rescue StandardError => e
            Rails.logger.error("Failed to pre-populate cache for country #{code}: #{e.message}")
            error_count += 1
          end
        end

        Rails.logger.info("Cache pre-population complete: #{success_count} succeeded, #{error_count} failed")
      else
        Rails.logger.info("No countries with votes found. Skipping cache pre-population.")
      end
    end
  rescue ActiveRecord::ConnectionNotEstablished => e
    Rails.logger.warn("Database not ready for cache pre-population: #{e.message}")
  rescue StandardError => e
    # Don't fail application startup if cache pre-population fails
    Rails.logger.error("Error during cache pre-population: #{e.message}")
    Rails.logger.error(e.backtrace.first(5).join("\n"))
  end
end
