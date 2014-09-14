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
      expect(json.keys).to contain_exactly('id', 'name', 'slug', 'parent', 'logo', 'domain', 'location', 'reviewers', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple entities" do
    it "returns the information for entity index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'slug', 'logo', 'parent', 'domain', 'location', 'created_at', 'updated_at')
    end
  end

  # Create entities
  describe "POST #entities" do
    context "not logged in" do
      before(:each) do
        entity = {
          name: "The Iron Yard",
          location: {
            address: "5990 Willow Ridge Road, Pinson, AL 35126"
          }
        }
        post "/entities", Oj.dump(entity), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single entity"
      it "returns the right value" do
        expect(json['name']).to eq('The Iron Yard')
        expect(json['slug']).to eq('theironyard')
        expect(json['location']['address']['address_1']).to eq('5990 Willow Ridge Road')
      end
    end
  end

  # Create entities
  describe "POST #entities/entities" do
    context "not logged in" do
      let(:n_entity) { create(:entity, :name => "Nashville") }
      let(:iy_entity) { create(:entity, :name => "The Iron Yard") }
      let!(:n2_entity) { create(:entity, :name => "Nashville", :parent => iy_entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{iy_entity.reviewers.first.account.api_key}"
        new_entity = {
          name: "Nashville",
          location: {
            coordinate: {
              lat: 36.0506082,
              lng: -86.7063188
            }
          }
        }
        post "/entities/#{iy_entity.id}/entities", Oj.dump(new_entity), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single entity"
      it "returns the right value" do
        expect(n2_entity.slug).to eq('nashville')
        expect(json['name']).to eq('Nashville')
        expect(json['slug']).to eq('nashville-2')
        expect(json['location']['coordinate']['lat']).to eq(36.0506082)

        saved_entity = Applyance::Entity.first(:id => json['id'])
        expect(saved_entity.reviewers.first.account_id).to eq(iy_entity.reviewers.first.account_id)
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
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        put "/entities/#{entity.id}", Oj.dump({ name: "Retail 2", location: { address: "5990 Willow Ridge Road\nPinson, AL 35126" } }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single entity"
      it "returns the right value" do
        expect(json['name']).to eq('Retail 2')
      end
      it "returns the right value" do
        expect(json['location']['address']['address_1']).to eq("5990 Willow Ridge Road")
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
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
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
