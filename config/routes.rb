Rails.application.routes.draw do
  # Devise routes for authentication (sign up, login, logout, etc.)
  devise_for :users

  # Root (landing page)
  root to: 'pages#home'

  # HABITS (owned by the currently logged-in user)
  resources :habits do
    resources :habit_logs, only: [:index, :create, :show, :update, :destroy]
    resources :tags, only: [:index, :create, :update, :destroy]
  end

  # BADGES (global resource)
  resources :badges, only: [:index, :show]
  resources :user_badges, only: [:create, :destroy]
end