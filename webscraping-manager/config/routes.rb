Rails.application.routes.draw do
  root to: 'home#index'

  resources :tasks, only: [:index, :new, :create, :edit, :update, :show, :destroy]

  # Sessão (Login/Logout)
  get    '/login',  to: 'sessions#new',     as: :login
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Cadastro (Registration)
  get  '/register', to: 'user_registrations#new',    as: :register
  post '/register', to: 'user_registrations#create'
end