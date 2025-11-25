module Api
  module V1
    class CountriesController < ApplicationController
      def top
        limit = params[:limit]&.to_i || 10
        search = params[:search]

        query = Countries::TopQuery.new(limit: limit, search: search)
        results = query.call

        render json: {
          countries: results.map do |result|
            {
              country_code: result[:country_code],
              vote_count: result[:vote_count],
              name: result[:metadata]&.dig(:name),
              official: result[:metadata]&.dig(:official),
              capital: result[:metadata]&.dig(:capital),
              region: result[:metadata]&.dig(:region),
              subregion: result[:metadata]&.dig(:subregion)
            }
          end
        }, status: :ok
      end

      def index
        client = Countries::Client.new
        countries = client.fetch_all

        render json: {
          countries: countries.map do |country|
            {
              code: country[:code],
              name: country[:name],
              official: country[:official]
            }
          end
        }, status: :ok
      end
    end
  end
end
