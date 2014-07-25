ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Admin do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:admins].delete
  end
  after(:all) do
  end

  shared_examples_for "a single admin" do
    it "returns the information for admin show" do
      expect(json.keys).to contain_exactly('id', 'account', 'entity', 'access_level', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple admins" do
    it "returns the information for admin index" do
      expect(json.first.keys).to contain_exactly('id', 'account_id', 'entity_id', 'access_level', 'created_at', 'updated_at')
    end
  end

  # Create admins
  describe "POST #admins" do
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) { post "/entities/#{entity.id}/admins", Oj.dump({ name: "Steve", email: "stjowa@gmail.com", password: "secret" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "a created object"
      it_behaves_like "a single admin"
      it "returns the right value" do
        expect(json['account']['name']).to eq('Steve')
        expect(json['account']['email']).to eq('stjowa@gmail.com')
        expect(json['access_level']).to eq('owner')
      end
    end
  end

  # Retrieve admins for entity
  describe "GET #admins" do
    context "logged in" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        get "/entities/#{entity.id}/admins"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple admins"
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        get "/entities/#{entity.id}/admins"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one admin
  describe "GET #admin" do
    context "logged in" do
      let(:admin) { create(:admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{admin.account.api_key}"
        get "/admins/#{admin.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single admin"
    end
    context "not logged in" do
      let(:admin) { create(:admin) }
      before(:each) { get "/admins/#{admin.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Update one admin
  describe "PUT #admin" do
    context "logged in" do
      let(:admin) { create(:admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{admin.account.api_key}"
        put "/admins/#{admin.id}", Oj.dump({ :access_level => "limited" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single admin"
      it "returns the right value" do
        expect(json['access_level']).to eq('limited')
      end
    end
    context "not logged in" do
      let(:admin) { create(:admin) }
      before(:each) { put "/admins/#{admin.id}", Oj.dump({ :access_level => "limited" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove admin
  describe "Delete #admin" do
    context "logged in as admin" do
      let(:admin) { create(:admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{admin.account.api_key}"
        delete "/admins/#{admin.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:admin) { create(:admin) }
      before(:each) { delete "/admins/#{admin.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
