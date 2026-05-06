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
  resources :tournaments, only: [ :new, :create ]
  # Public tournament view (share link)
  get "t/:share_token", to: "tournaments#show", as: :public_tournament

  # Admin tournament view
  get "t/:share_token/admin/:admin_token", to: "tournaments#admin:", as: :admin_tournament
end
