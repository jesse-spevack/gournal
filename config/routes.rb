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
  get "settings/help" => "settings#help", as: :settings_help

  # Habits management (authenticated)
  resources :habits, only: [ :create, :update, :destroy ]

  # Habit entries routes
  resources :habit_entries, only: [ :index, :update ]

  # Daily reflections - top level resource since they belong to users
  resources :daily_reflections, only: [ :create, :update ]

  # Defines the root path route ("/")
  root "habit_entries#index"
end#
