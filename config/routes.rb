# frozen_string_literal: true

Rails.application.routes.draw do
  get 'api/callbacks/discord', to: 'callbacks#receive_discord_callback'
end
