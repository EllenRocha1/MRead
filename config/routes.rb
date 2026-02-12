Rails.application.routes.draw do
  devise_for :users
  
  resources :books do
    collection do
      get :search
    end
  end

  root "books#index"
  
  get "up" => "rails/health#show", as: :rails_health_check
end