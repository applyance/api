ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Profile do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:pipelines].delete
    app.db[:labels].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single profile" do
    it "returns the information for profile show" do
      expect(json.keys).to contain_exactly('id', 'account', 'location', 'phone_number', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple profiles" do
    it "returns the information for profile index" do
      expect(json.first.keys).to contain_exactly('id', 'account', 'location_id', 'phone_number', 'created_at', 'updated_at')
    end
  end

  # Retrieve one profile
  describe "GET #profile" do
    context "logged in as reviewer" do
      let(:profile) { create(:profile) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{profile.account.api_key}"
        get "/profiles/#{profile.account_id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single profile"
    end
    context "not logged in" do
      let(:profile) { create(:profile) }
      before(:each) do
        get "/profiles/#{profile.account_id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update profile
  describe "PUT #profile" do
    context "logged in as reviewer" do
      let(:profile) { create(:profile) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{profile.account.api_key}"
        put "/profiles/#{profile.id}", Oj.dump({ phone_number: "205-555-5555" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single profile"
    end
    context "not logged in" do
      let(:profile) { create(:profile) }
      before(:each) do
        put "/profiles/#{profile.id}", Oj.dump({ phone_number: "205-555-5555" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove profile
  describe "Delete #profile" do
    context "logged in as reviewer" do
      let(:profile) { create(:profile) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{profile.account.api_key}"
        delete "/profiles/#{profile.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:profile) { create(:profile) }
      before(:each) do
        delete "/profiles/#{profile.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
