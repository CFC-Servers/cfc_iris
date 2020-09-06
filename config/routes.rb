# frozen_string_literal: true

Rails.application.routes.draw do
  scope 'api' do
    get 'callbacks/discord', to: 'callbacks#receive_discord_callback'
    get 'users/:id', to: 'users#get'
    get 'users/find', to: 'users#find_user'
    get 'users/steam_ids', to: 'users#steam_ids'
    post 'ranks/bulk_update', to: 'ranks#update_ranks'
  end
end
