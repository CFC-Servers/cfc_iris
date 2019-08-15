Rails.application.routes.draw do
  namespace :api do
    resources :users

    post "test", to: "users#test"
  end
end
