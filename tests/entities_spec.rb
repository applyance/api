ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'

RSpec.describe 'Do entities work?' do
  include Rack::Test::Methods

  def app
    @app ||= Applyance::Server
  end

  before(:all) do
  end

  it "Registers reviewer" do
    account = { :name => "Steve", :email => "stjowa@gmail.com", :password => "testing" }
    entity = { :name => "Frothy Monkey" }

    post "/reviewers/register", { account: account, entity: entity }

    expect(last_response.status).to eq(201)
  end

  it "Retrieves entity" do
    account = Account.first(:email => "stjowa@gmail.com")
    entity = Entity.first(:name => "Frothy Monkey")

    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"

    get "/entities/#{entity.id}"

    expect(last_response).to be_ok

    # Make sure response is equal
    expect(last_response.body).to eq(Oj.dump(entity.values.slice(:id, :name, :created_at, :updated_at)))
  end

  it "Deletes entity" do
    account = Account.first(:email => "stjowa@gmail.com")
    entity = Entity.first(:name => "Frothy Monkey")

    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"

    delete "/entities/#{entity.id}"

    expect(last_response.status).to eq(204)
  end

  after(:all) do
    app.settings.db.run("delete from accounts_roles")
    EntityMember.dataset.delete
    Account.dataset.delete
    Entity.dataset.delete
  end

end
