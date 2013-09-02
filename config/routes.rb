#Rails.application.routes.draw
Geopolitical::Engine.routes.draw do
  resources :cities
  resources :regions
  resources :countries

  resource :geopolitical

  root :to => "geopolitical#index"
end
