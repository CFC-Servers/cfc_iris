Rails.application.routes.draw do
  resources :users

  post "test", to: "users#test"
end
