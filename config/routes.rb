Rails.application.routes.draw do
  resources :devices, only: [:create] do
    collection do
      post :status
    end
  end
  resources :metrics, only: [:create]
end
