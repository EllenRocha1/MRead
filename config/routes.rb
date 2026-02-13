Rails.application.routes.draw do
  root "books#index"
  devise_for :users

  resources :books do
    collection do
      get 'search'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end