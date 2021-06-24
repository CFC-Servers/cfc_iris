# frozen_string_literal: true

Rails.application.routes.draw do
  scope 'api' do
    get 'callbacks/discord', to: 'callbacks#receive_discord_callback'
    get 'users/:id', to: 'users#get'
    get 'sessions/:uuid', to: 'callback_sessions#get'
    post 'users/find', to: 'users#find_user'
    post 'users/reset', to: 'users#reset'
    post 'ranks/bulk_update', to: 'ranks#update_ranks'
  end
end
