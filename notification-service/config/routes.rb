Rails.application.routes.draw do
  post '/notifications', to: 'notifications#create'
  get "up" => "rails/health#show", as: :rails_health_check
end
