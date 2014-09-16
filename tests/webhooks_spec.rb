ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Routing::Webhooks do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
  end
  after(:all) do
  end

  # Stripe webhook
  describe "POST #webhooks/stripe" do
    before(:each) do
      post "/webhooks/stripe", JSON.dump({}), { "CONTENT_TYPE" => "application/json" }
    end

    it_behaves_like "a retrieved object"
  end

end
