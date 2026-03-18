Rails.application.routes.draw do
  get "pages/home"
  # Devise routes for authentication (sign up, login, logout, etc.)
  devise_for :users

  # Root (landing page)
  root to: 'pages#home'

  # Temporary aliases used by the current UI
  get "dashboard", to: "habits#index", as: :dashboard
  get "statistics", to: "badges#index", as: :statistics

  # HABITS (owned by the currently logged-in user)
  resources :habits do
    resources :habit_logs, only: [:index, :create, :show, :update, :destroy]
    resources :tags, only: [:index, :create, :update, :destroy]
  end

  # BADGES (global resource)
  resources :badges, only: [:index, :show]
  resources :user_badges, only: [:create, :destroy]
end
