module Api
  module V1
    class VotesController < ApplicationController
      def create
        service = Votes::Create.new(
          name: vote_params[:name],
          email: vote_params[:email],
          country_code: vote_params[:country_code]
        )

        if service.call
          render json: {
            vote: {
              id: service.vote.id,
              country_code: service.vote.country_code,
              created_at: service.vote.created_at
            },
            user: {
              id: service.vote.user.id,
              name: service.vote.user.name,
              email: service.vote.user.email
            }
          }, status: :created
        else
          if service.errors.any? { |e| e.include?("has already been taken") }
            render json: { error: "User has already voted" }, status: :conflict
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end
      end

      private

      def vote_params
        params.require(:vote).permit(:name, :email, :country_code)
      end
    end
  end
end
