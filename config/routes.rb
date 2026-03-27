Rails.application.routes.draw do
  # Devise routes for authentication (sign up, login, logout, etc.)
  devise_for :users

  # Root (landing page)
  root "pages#home"

  # Static and dashboard pages
  controller :pages do
    get "pages/home", action: :home, as: :pages_home
    get "dashboard", action: :dashboard, as: :dashboard
    get "terms", action: :terms, as: :terms
    get "cookies", action: :cookie_policy, as: :cookies
  end

  get "cgu", to: redirect("/terms")

  resource :cookie_consent, only: %i[create destroy]
  resource :profile_avatar, only: :update

  # Statistics pages
  scope :statistics, controller: :badges, as: :statistics do
    get "/", action: :index
    get "badge_collection", action: :collection, as: :badge_collection
  end

  # HABITS (owned by the currently logged-in user)
  resources :habits, except: %i[index new show edit] do
    resources :habit_logs, only: %i[index create show update destroy]
    resources :tags, only: %i[index create update destroy]
  end

  # BADGES (global resource)
  resources :badges, only: %i[index show]
  resources :user_badges, only: %i[create destroy]
end
