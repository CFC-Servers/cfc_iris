# frozen_string_literal: true

Rails.application.routes.draw do
  get 'api/callbacks/discord', to: 'callbacks#receive_discord_callback'
  get 'api/find_user', to: 'users#find_user'
end
