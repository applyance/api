ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Definition do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:definitions].delete
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:spots].delete
  end
  after(:all) do
  end

  shared_examples_for "a single definition" do
    it "returns the information for definition show" do
      expect(json.keys).to contain_exactly('id', 'name', 'slug', 'domain', 'entity', 'label', 'description', 'type', 'helper', 'placeholder', 'is_sensitive', 'is_contextual', 'is_core', 'is_default', 'default_position', 'default_is_required', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple definitions" do
    it "returns the information for definition index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'slug', 'domain', 'label', 'description', 'type', 'helper', 'placeholder', 'is_sensitive', 'is_contextual', 'is_core', 'is_default', 'default_position', 'default_is_required', 'created_at', 'updated_at')
    end
  end

  # Create definitions
  describe "POST #entities/definitions" do
    context "logged in as admin" do
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        post "/entities/#{entity.id}/definitions", Oj.dump({ name: "Question 1", label: "Question 1", description: "Detail...", type: "text" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single definition"
      it "returns the right value" do
        expect(json['label']).to eq('Question 1')
        expect(json['description']).to eq('Detail...')
      end
    end
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) { post "/entities/#{entity.id}/definitions", Oj.dump({ name: "Question 1", label: "Question 1", description: "Detail...", type: "text" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Create definitions
  describe "POST #domains/definitions" do
    context "logged in as admin" do
      let(:account) { create(:chief_account) }
      let(:domain) { create(:domain) }
      before(:each) do
        account_auth
        post "/domains/#{domain.id}/definitions", Oj.dump({ name: "Question 1", label: "Question 1", description: "Detail...", type: "text" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single definition"
      it "returns the right value" do
        expect(json['label']).to eq('Question 1')
        expect(json['description']).to eq('Detail...')
      end
    end
    context "not logged in" do
      let(:domain) { create(:domain) }
      before(:each) { post "/domains/#{domain.id}/definitions", Oj.dump({ name: "Question 1", label: "Question 1", description: "Detail...", type: "text" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Create definitions
  describe "POST #definitions" do
    context "logged in as admin" do
      let(:account) { create(:chief_account) }
      before(:each) do
        account_auth
        post "/definitions", Oj.dump({ name: "Question 1", label: "Question 1", description: "Detail...", type: "text" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single definition"
      it "returns the right value" do
        expect(json['label']).to eq('Question 1')
        expect(json['description']).to eq('Detail...')
      end
    end
    context "not logged in" do
      before(:each) { post "/definitions", Oj.dump({ name: "Question 1", label: "Question 1", description: "Detail...", type: "text" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve definitions
  describe "GET #definitions" do
    context "not logged in" do
      let!(:definition) { create(:definition) }
      let!(:entity) { create(:entity_with_definition) }
      before(:each) do
        get "/definitions"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple definitions"
      it "returns the right number of definitions" do
        expect(json.count).to eq(1)
      end
    end
  end

  # Retrieve definitions
  describe "GET #domain/definitions" do
    context "not logged in" do
      let(:domain) { create(:domain_with_definition) }
      before(:each) do
        get "/domains/#{domain.id}/definitions"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple definitions"
    end
  end

  # Retrieve definitions
  describe "GET #unit/definitions" do
    context "logged in " do
      let(:entity) { create(:entity_with_definition) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        get "/entities/#{entity.id}/definitions"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple definitions"
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_definition) }
      before(:each) do
        get "/entities/#{entity.id}/definitions"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one definition
  describe "GET #definition" do
    let(:definition) { create(:definition) }
    before(:each) { get "/definitions/#{definition.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single definition"
  end

  # Update definition
  describe "PUT #definition" do
    context "logged in as admin" do
      let(:entity) { create(:entity_with_definition) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        put "/definitions/#{entity.definitions.first.id}", Oj.dump({ label: "Definition Change" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single definition"
      it "returns the right value" do
        expect(json['label']).to eq('Definition Change')
      end
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_definition) }
      before(:each) { put "/definitions/#{entity.definitions.first.id}", Oj.dump({ label: "The Iron Yard" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove definition
  describe "Delete #definition" do
    context "logged in as admin" do
      let(:entity) { create(:entity_with_definition) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        delete "/definitions/#{entity.definitions.first.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_definition) }
      before(:each) { delete "/definitions/#{entity.definitions.first.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
