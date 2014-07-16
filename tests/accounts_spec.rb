ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'

RSpec.describe 'Do accounts work?' do
  include Rack::Test::Methods

  def app
    @app ||= Applyance::Server
  end

  it "create reviewer" do
    account = { :name => "Steve", :email => "stjowa@gmail.com", :password => "testing" }
    post "/accounts", account
    expect(last_response).to be_ok
    expect(Oj.load(last_response.body, :symbol_keys => true)).to include(account.except(:password))
  end

  it "show account" do
    @account = Account.first(:email => "stjowa@gmail.com")
    header "Authorization", "ApplyanceLogin auth=#{@account.api_key}"
    get "/accounts/#{@account.pk}"
    expect(last_response).to be_ok
    expect(last_response.body).to eq(Oj.dump(@account.values.slice(:id, :name, :email, :is_verified)))
  end

  after(:all) do
    Account.dataset.delete
  end

end
