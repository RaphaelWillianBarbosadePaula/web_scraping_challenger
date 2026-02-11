Rails.application.routes.draw do
  post '/notifications', to: 'notifications#create'
  get '/notifications', to: 'notifications#index'
  get "up" => "rails/health#show", as: :rails_health_check
end
