Rails.application.routes.draw do
  resources :devices, only: [:create]
  resources :metrics, only: [:create]
end
