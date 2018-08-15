# require 'json'
# require 'ostruct'

require_relative 'v1/base'

module RoundedServices
  module API
    class V1 < Sinatra::Base
      namespace '/v1' do
        get '/status' do
          body "#{@config.env} up and running."
        end
      end
    end
  end
end

require_relative 'v1/account'
require_relative 'v1/job_listing'
