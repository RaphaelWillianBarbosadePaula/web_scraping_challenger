Rails.application.routes.draw do
  resources :users

  # Custom routes
  post "/login", to: "authentication#login"
  get "up" => "rails/health#show", as: :rails_health_check
end
