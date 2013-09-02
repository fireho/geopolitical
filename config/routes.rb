#Rails.application.routes.draw
Geopolitical::Engine.routes.draw do
  resources :cities
  resources :provinces
  resources :countries

  resource :geopolitical

  root :to => "geopolitical#index"
end
