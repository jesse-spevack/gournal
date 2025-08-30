Rails.application.routes.draw do
  resource :session
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Custom route for month/year grid (ID=1 is the placeholder)
  get "habits/1", to: "habits#show", as: :habit_month_grid, defaults: { id: "1" }

  # Habits resource
  resources :habits do
    resources :habit_entries, only: [ :update ]
  end

  # Special route for creating/updating habit entries with habit_id and day
  patch "habit_entries/habit/:habit_id/day/:day", to: "habit_entries#update", as: :habit_entry_by_habit_and_day

  # Standalone habit entries routes for bulk operations and direct access
  resources :habit_entries, only: [ :update ]

  # Style guide
  get "style_guide" => "style_guide#index", as: :style_guide

  # Defines the root path route ("/")
  root "habits#index"
end#
