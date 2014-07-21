ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Role do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:all) do
  end

  shared_examples_for "a single role" do
    it "returns the information for role show" do
      expect(json.keys).to contain_exactly('id', 'name')
    end
  end

  shared_examples_for "multiple roles" do
    it "returns the information for role index" do
      expect(json.first.keys).to contain_exactly('id', 'name')
    end
  end

  # Retrieve roles
  describe "GET #roles" do
    before(:each) { get "/roles" }

    it_behaves_like "a retrieved object"
    it_behaves_like "multiple roles"
  end

  # Retrieve one role
  describe "GET #role" do
    before(:each) { get "/roles/#{Applyance::Role.first.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single role"
  end

end
