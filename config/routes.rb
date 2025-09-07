Rails.application.routes.draw do
  resource :session
  resources :users, only: [ :new, :create ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Style guide
  get "style_guide" => "style_guide#index", as: :style_guide

  # Settings (authenticated)
  get "settings" => "settings#index", as: :settings
  patch "settings" => "settings#update"

  # Help system (authenticated)
  get "help/manage-habits" => "help#manage_habits", as: :help_manage_habits
  get "help/next-month-setup" => "help#next_month_setup", as: :help_next_month_setup
  get "help/profile-sharing" => "help#profile_sharing", as: :help_profile_sharing

  # Batch position updates for habits (must come before generic :habits routes)
  namespace :habits do
    resource :positions, only: [ :update ]
  end

  # Month setup actions (authenticated)
  resources :month_setups, only: [ :create ]

  # Habits management (authenticated)
  resources :habits, only: [ :new, :create, :update, :destroy ]

  # Habit entries routes
  get "habit_entries/:year/:month", to: "habit_entries#index", as: :habit_entries_month,
      constraints: { year: /\d{4}/, month: /\d{1,2}/ }
  resources :habit_entries, only: [ :index, :update ]

  # Daily reflections - top level resource since they belong to users
  resources :daily_reflections, only: [ :create, :update ]

  # Defines the root path route ("/")
  root "habit_entries#index"

  # Catch-all routes for public profiles (must be last to avoid conflicts)
  get "/:slug/:year/:month", to: "public_profiles#show", as: :public_profile_month,
      constraints: { slug: /[a-z0-9_-]+/, year: /\d{4}/, month: /\d{1,2}/ }
  get "/:slug", to: "public_profiles#show", as: :public_profile,
      constraints: { slug: /[a-z0-9_-]+/ }
end
