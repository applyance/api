ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'

RSpec.describe 'Do roles work?' do
  include Rack::Test::Methods

  def app
    @app ||= Applyance::Server
  end

  before(:all) do
    Applyance::Server.db[:roles].insert(:name => "applicant")
    Applyance::Server.db[:roles].insert(:name => "admin")
    Applyance::Server.db[:roles].insert(:name => "reviewer")
  end

  it "Retrieves roles" do
    get "/roles"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(Oj.dump(Applyance::Role.all))
  end

  it "Retrieves role" do
    test_role = Applyance::Role.first(:name => "admin")

    get "/roles/#{test_role.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(Oj.dump(test_role))
  end

  after(:all) do
    Applyance::Server.db[:roles].delete
  end

end
