Rails.application.routes.draw do
  # get "pages/home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  # Tournaments
  resources :tournaments, only: [ :index, :new, :create ]

  # Public tournament view (share link)
  get "t/:share_token", to: "tournaments#show", as: :public_tournament

  # Admin tournament view
  get "t/:share_token/admin/:admin_token", to: "tournaments#admin", as: :admin_tournament

  # Start tournament
  post "t/:share_token/admin/:admin_token/start", to: "tournaments#start", as: :start_tournament

  # Player management (admin only)
  post "t/:share_token/admin/:admin_token/players", to: "players#create", as: :tournament_players
  delete "t/:share_token/admin/:admin_token/players/:id", to: "players#destroy", as: :tournament_player
end
