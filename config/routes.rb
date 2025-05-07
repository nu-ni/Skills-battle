Rails.application.routes.draw do
  get "mazes/index"
  get "mazes/new"
  get "mazes/play"
  get "pages/welcome"
  get "pages/menu"

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#welcome"

  post "/set_name", to: "pages#set_name"
  get "/menu", to: "pages#menu"

  # Update the resources line to include :edit and :update actions
  resources :mazes, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      get :play
      get :auto_solve
      post :solve
    end
  end
end
