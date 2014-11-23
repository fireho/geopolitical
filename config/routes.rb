# Rails.application.routes.draw
Geopolitical::Engine.routes.draw do
  resources :hoods
  resources :cities
  resources :regions
  resources :nations

  resource :geopolitical

  root to: 'geopolitical#index'
end
