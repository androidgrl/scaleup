Rails.application.routes.draw do

  get "/400", :to  => "errors#bad_request"
  get "/404", :to  => "errors#not_found"
  get "/500", :to  => "errors#internal_server_error"

  root "home#index"

  get "/browse", to: "loan_requests#index"

  resources :categories, only: [:show]

  get "/portfolio", to: "borrower_portfolio#show"

  resources :payment, only: [:update]

  resources :loan_requests

  get "/cart", to: "cart#index"
  post "/cart", to: "cart#create"
  delete "/cart", to: "cart#delete"
  put "/cart", to: "cart#update"

  resources :orders, only: [:create, :index, :show, :update]

  get "/login", to: "sessions#new", :as => "login"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"
  delete "/logout", to: "sessions#destroy"

  resources :lenders

  resources :borrowers

  resources :users, only: [:show]
end
