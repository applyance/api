ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Entity do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:entities].delete
    app.db[:domains].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single entity" do
    it "returns the information for entity show" do
      expect(json.keys).to contain_exactly('id', 'name', 'logo', 'domain', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple entities" do
    it "returns the information for entity index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'logo', 'domain_id', 'created_at', 'updated_at')
    end
  end

  # Create entities
  describe "POST #entities" do
    context "not logged in" do
      before(:each) { post "/entities", Oj.dump({ name: "The Iron Yard" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "a created object"
      it_behaves_like "a single entity"
      it "returns the right value" do
        expect(json['name']).to eq('The Iron Yard')
      end
    end
  end

  # Retrieve entities
  describe "GET #entities" do
    context "logged in as chief" do
      let!(:account) { create(:chief_account) }
      let!(:entities) { create_list(:entity, 3) }
      before(:each) do
        account_auth
        get "/entities"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of entities" do
        expect(json.count).to eq(3)
      end
      it_behaves_like "multiple entities"
    end
    context "not logged in" do
      let!(:entities) { create_list(:entity, 3) }
      before(:each) do
        get "/entities"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve domain entities
  describe "GET #entities" do
    context "logged in as chief" do
      let!(:account) { create(:chief_account) }
      let!(:entities) { create_list(:entity, 3) }
      before(:each) do
        account_auth
        get "/domains/#{entities.first.domain.id}/entities"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple entities"
    end
    context "not logged in" do
      let!(:entities) { create_list(:entity, 3) }
      before(:each) do
        get "/domains/#{entities.first.domain.id}/entities"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one entity
  describe "GET #entity" do
    let(:entity) { create(:entity) }
    before(:each) { get "/entities/#{entity.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single entity"
  end

  # Update entity
  describe "PUT #entity" do
    context "logged in as admin" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        put "/entities/#{entity.id}", { name: "Retail 2" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single entity"
      it "returns the right value" do
        expect(json['name']).to eq('Retail 2')
      end
    end
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) { put "/entities/#{entity.id}", Oj.dump({ name: "The Iron Yard" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove entity
  describe "Delete #entity" do
    context "logged in as admin" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        delete "/entities/#{entity.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) { delete "/entities/#{entity.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
