ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Rating do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:entities].delete
    app.db[:blueprints].delete
    app.db[:definitions].delete
    app.db[:datums].delete
    app.db[:fields].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:applications].delete
    app.db[:ratings].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single rating" do
    it "returns the information for rating show" do
      expect(json.keys).to contain_exactly('id', 'rating', 'application', 'account', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple ratings" do
    it "returns the information for rating index" do
      expect(json.first.keys).to contain_exactly('id', 'rating', 'application_id', 'account_id', 'created_at', 'updated_at')
    end
  end

  # Create ratings
  describe "POST #accounts/rating" do
    context "logged in as reviewer" do
      let!(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.entities.first.reviewers.first.account.api_key}"
        post "/accounts/#{application.entities.first.reviewers.first.account.id}/ratings", Oj.dump({ rating: 3, application_id: application.id, entity_id: application.entities.first.id }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single rating"
      it "returns the right value" do
        expect(json['rating']).to eq(3)
      end
    end
    context "not logged in" do
      let!(:application) { create(:application) }
      before(:each) do
        post "/accounts/#{application.entities.first.reviewers.first.account.id}/ratings", Oj.dump({ rating: 3, application_id: application.id, entity_id: application.entities.first.id }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve ratings
  describe "GET #ratings" do
    context "logged in as chief" do
      let(:rating) { create(:rating) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{rating.application.entities.first.reviewers.first.account.api_key}"
        get "/applications/#{rating.application.id}/ratings"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of ratings" do
        expect(json.count).to eq(1)
      end
      it_behaves_like "multiple ratings"
    end
    context "not logged in" do
      let(:rating) { create(:rating) }
      before(:each) do
        get "/applications/#{rating.application.id}/ratings"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one rating
  describe "GET #rating" do
    context "logged in as reviewer" do
      let(:rating) { create(:rating) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{rating.application.entities.first.reviewers.first.account.api_key}"
        get "/ratings/#{rating.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single rating"
    end
    context "not logged in" do
      let(:rating) { create(:rating) }
      before(:each) do
        get "/ratings/#{rating.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update rating
  describe "PUT #rating" do
    context "logged in as reviewer" do
      let(:rating) { create(:rating) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{rating.account.api_key}"
        put "/ratings/#{rating.id}", Oj.dump({ rating: 4 }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single rating"
      it "returns the right value" do
        expect(json['rating']).to eq(4)
      end
    end
    context "not logged in" do
      let(:rating) { create(:rating) }
      before(:each) do
        put "/ratings/#{rating.id}", Oj.dump({ rating: 4 }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove rating
  describe "Delete #rating" do
    context "logged in as reviewer" do
      let(:rating) { create(:rating) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{rating.account.api_key}"
        delete "/ratings/#{rating.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:rating) { create(:rating) }
      before(:each) do
        delete "/ratings/#{rating.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
