require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq dashboard with basic auth
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_USERNAME", "admin"))
    ) &
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(password),
        ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_PASSWORD", "changeme"))
      )
  end

  mount Sidekiq::Web => "/sidekiq"

  # API routes
  namespace :api do
    namespace :v1 do
      resources :votes, only: [:create]
      resources :countries, only: [:index] do
        collection do
          get :top
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
