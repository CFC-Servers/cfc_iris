# frozen_string_literal: true

class CallbackSession < ApplicationRecord
  #default_scope { where(active: true) }

  before_create do
    self.uuid = SecureRandom.uuid
  end

  def transform_results
    JSON.parse(results).each_with_object({}) do |result, hash|
      platform = result['platform']

      hash[platform] ||= []
      hash[platform] << result.except('platform')
    end
  end
end
