ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Reviewer do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:reviewers].delete
    app.db[:entities].delete
    app.db[:domains].delete
  end
  after(:all) do
  end

  shared_examples_for "a single reviewer" do
    it "returns the information for reviewer show" do
      expect(json.keys).to contain_exactly('id', 'account', 'entity', 'scope', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple reviewers" do
    it "returns the information for reviewer index" do
      expect(json.first.keys).to contain_exactly('id', 'account', 'entity_id', 'scope', 'created_at', 'updated_at')
    end
  end

  # Create reviewer for entity
  describe "POST #entity/:id/reviewers" do
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        reviewer = {
          "name" => "Stephen Joseph Watkins",
          "email" => "stjowa@gmail.com",
          "password" => "whaddup"
        }
        post "/entities/#{entity.id}/reviewers", Oj.dump(reviewer), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single reviewer"
      it "returns the right value" do
        expect(json['account']['name']).to eq('Stephen Joseph Watkins')
        expect(json['account']['first_name']).to eq('Stephen Joseph')
        expect(json['account']['last_name']).to eq('Watkins')
        expect(json['account']['initials']).to eq('SW')
        expect(json['account']['email']).to eq('stjowa@gmail.com')
      end
    end
  end

  # Retrieve reviewers for entity
  describe "GET #reviewers" do
    context "logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        get "/entities/#{entity.id}/reviewers"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple reviewers"
    end
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        get "/entities/#{entity.id}/reviewers"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one reviewer
  describe "GET #reviewer" do
    context "logged in" do
      let(:reviewer) { create(:reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{reviewer.account.api_key}"
        get "/reviewers/#{reviewer.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single reviewer"
    end
    context "not logged in" do
      let(:reviewer) { create(:reviewer) }
      before(:each) { get "/reviewers/#{reviewer.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Update one reviewer
  describe "PUT #reviewer" do
    context "logged in" do
      let(:reviewer) { create(:reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{reviewer.account.api_key}"
        put "/reviewers/#{reviewer.id}", Oj.dump({ :scope => "limited" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single reviewer"
      it "returns the right value" do
        expect(json['scope']).to eq('limited')
      end
    end
    context "not logged in" do
      let(:reviewer) { create(:reviewer) }
      before(:each) { put "/reviewers/#{reviewer.id}", Oj.dump({ :scope => "limited" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove reviewer
  describe "Delete #reviewer" do
    context "logged in as reviewer" do
      let(:reviewer) { create(:reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{reviewer.account.api_key}"
        delete "/reviewers/#{reviewer.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:reviewer) { create(:reviewer) }
      before(:each) { delete "/reviewers/#{reviewer.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
