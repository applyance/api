ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Blueprint do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:blueprints].delete
    app.db[:definitions].delete
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:spots].delete
  end
  after(:all) do
  end

  shared_examples_for "a single blueprint" do
    it "returns the information for blueprint show" do
      expect(json.keys).to contain_exactly('id', 'definition', 'spot', 'entity', 'position', 'is_required', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple blueprints" do
    it "returns the information for blueprint index" do
      expect(json.first.keys).to contain_exactly('id', 'definition', 'position', 'spot', 'entity', 'is_required', 'created_at', 'updated_at')
    end
  end

  # Update blueprint
  describe "PUT #blueprint" do
    context "logged in as admin" do
      let(:blueprint) { create(:blueprint_with_entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{blueprint.entity.reviewers.first.account.api_key}"
        put "/blueprints/#{blueprint.id}", Oj.dump({ position: 2 }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single blueprint"
      it "returns the right value" do
        expect(json['position']).to eq(2)
      end
    end
    context "not logged in" do
      let(:blueprint) { create(:blueprint_with_entity) }
      before(:each) { put "/blueprints/#{blueprint.id}", Oj.dump({ position: 2 }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove blueprint
  describe "Delete #blueprint" do
    context "logged in as admin" do
      let(:blueprint) { create(:blueprint_with_entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{blueprint.entity.reviewers.first.account.api_key}"
        delete "/blueprints/#{blueprint.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:blueprint) { create(:blueprint_with_entity) }
      before(:each) { delete "/blueprints/#{blueprint.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve spots/blueprints
  describe "GET #spots/blueprints" do
    context "logged in " do
      let(:blueprint) { create(:blueprint_with_spot) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{blueprint.spot.entity.reviewers.first.account.api_key}"
        get "/spots/#{blueprint.spot.id}/blueprints"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple blueprints"
    end
    context "not logged in" do
      let(:blueprint) { create(:blueprint_with_spot) }
      before(:each) do
        get "/spots/#{blueprint.spot.id}/blueprints"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple blueprints"
    end
  end

  # Retrieve entities/blueprints
  describe "GET #entities/blueprints" do
    context "logged in " do
      let(:blueprint) { create(:blueprint_with_entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{blueprint.entity.reviewers.first.account.api_key}"
        get "/entities/#{blueprint.entity.id}/blueprints"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple blueprints"
    end
    context "not logged in" do
      let(:blueprint) { create(:blueprint_with_entity) }
      before(:each) do
        get "/entities/#{blueprint.entity.id}/blueprints"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple blueprints"
    end
  end

  # Retrieve one blueprint
  describe "GET #blueprint" do
    let(:blueprint) { create(:blueprint) }
    before(:each) { get "/blueprints/#{blueprint.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single blueprint"
  end

  # Create blueprints for entities
  describe "POST #entities/blueprints" do
    context "logged in as full reviewer" do
      let(:definition) { create(:definition) }
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        post "/entities/#{entity.id}/blueprints", Oj.dump({ definition_id: definition.id, position: 1, is_required: false }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single blueprint"
      it "returns the right value" do
        expect(json['position']).to eq(1)
        expect(json['is_required']).to eq(false)
      end
    end
    context "not logged in" do
      let(:definition) { create(:definition) }
      let(:entity) { create(:entity) }
      before(:each) { post "/entities/#{entity.id}/blueprints", Oj.dump({ definition_id: definition.id, position: 1, is_required: false }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Create blueprints for spots
  describe "POST #spots/blueprints" do
    context "logged in as full reviewer" do
      let(:definition) { create(:definition) }
      let(:spot) { create(:spot) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{spot.entity.reviewers.first.account.api_key}"
        post "/spots/#{spot.id}/blueprints", Oj.dump({ definition_id: definition.id, position: 1, is_required: false }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single blueprint"
      it "returns the right value" do
        expect(json['position']).to eq(1)
        expect(json['is_required']).to eq(false)
      end
    end
    context "not logged in" do
      let(:definition) { create(:definition) }
      let(:spot) { create(:spot) }
      before(:each) { post "/spots/#{spot.id}/blueprints", Oj.dump({ definition_id: definition.id, position: 1, is_required: false }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

end
