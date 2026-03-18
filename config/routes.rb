Rails.application.routes.draw do
  get "pages/home"
  # Devise routes for authentication (sign up, login, logout, etc.)
  devise_for :users

  # Root (landing page)
  root to: 'pages#home'

  # Main connected pages
  get "dashboard", to: "pages#dashboard", as: :dashboard
  get "statistics", to: "badges#index", as: :statistics

  # HABITS (owned by the currently logged-in user)
  resources :habits, except: [:index, :new, :show, :edit] do
    resources :habit_logs, only: [:index, :create, :show, :update, :destroy]
    resources :tags, only: [:index, :create, :update, :destroy]
  end

  # BADGES (global resource)
  resources :badges, only: [:index, :show]
  resources :user_badges, only: [:create, :destroy]
end
