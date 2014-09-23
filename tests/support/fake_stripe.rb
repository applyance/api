require 'sinatra/base'

module Applyance
  module Test
    class FakeStripe < Sinatra::Base

      post '/v1/customers' do
        json_response(200, 'customer.json')
      end

      get '/v1/customers/:customer_id' do
        json_response(200, 'customer.json')
      end

      get '/v1/customers/:customer_id/subscriptions/:subscription_id' do
        json_response(200, 'subscription.json')
      end

      post '/v1/customers/:customer_id/subscriptions/:subscription_id' do
        json_response(200, 'subscription.json')
      end

      post '/v1/customers/:customer_id/subscriptions' do
        json_response(200, 'subscription.json')
      end

      private
        def json_response(response_code, file_name)
          content_type :json
          status response_code
          File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
        end
    end
  end
end
