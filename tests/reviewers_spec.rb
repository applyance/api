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
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:admins].delete
    app.db[:units].delete
    app.db[:reviewers].delete
  end
  after(:all) do
  end

  shared_examples_for "a single reviewer" do
    it "returns the information for reviewer show" do
      expect(json.keys).to contain_exactly('id', 'account', 'unit', 'access_level', 'is_entity_admin', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple reviewers" do
    it "returns the information for reviewer index" do
      expect(json.first.keys).to contain_exactly('id', 'account_id', 'unit_id', 'access_level', 'is_entity_admin', 'created_at', 'updated_at')
    end
  end

  # Retrieve reviewers for unit
  describe "GET #reviewers" do
    context "logged in" do
      let(:unit) { create(:unit) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        get "/units/#{unit.id}/reviewers"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple reviewers"
    end
    context "not logged in" do
      let(:unit) { create(:unit) }
      before(:each) do
        get "/units/#{unit.id}/reviewers"
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
