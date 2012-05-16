Geopolitical::Engine.routes.draw do
#Rails.application.routes.draw do
  resources :cities
  resources :provinces
  resources :countries

  resource :geopolitical

  root :to => "geopolitical#index"

end
