ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::ReviewerInvite do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:reviewers].delete
    app.db[:reviewer_invites].delete
    app.db[:entities].delete
    app.db[:domains].delete
  end
  after(:all) do
  end

  shared_examples_for "a single reviewer invite" do
    it "returns the information for reviewer invite show" do
      expect(json.keys).to contain_exactly('id', 'entity', 'email', 'status', 'scope', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple reviewer invites" do
    it "returns the information for reviewer invite index" do
      expect(json.first.keys).to contain_exactly('id', 'entity_id', 'email', 'status', 'scope', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "a single reviewer" do
    it "returns the information for reviewer show" do
      expect(json.keys).to contain_exactly('id', 'account', 'entity', 'scope', 'created_at', 'updated_at')
    end
  end

  # Create reviewer invite
  describe "POST #reviewer/invites" do
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        post "/entities/#{entity.id}/reviewers/invites", Oj.dump({ email: "stjowa@gmail.com", scope: "admin" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
    context "logged in as admin" do
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        post "/entities/#{entity.id}/reviewers/invites", Oj.dump({ email: "stjowa@gmail.com", scope: "full" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single reviewer invite"
      it "returns the right value" do
        expect(json['email']).to eq('stjowa@gmail.com')
      end
    end
  end

  # Retrieve reviewer invites for unit
  describe "GET #reviewer/invites" do
    context "logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        get "/entities/#{entity.id}/reviewers/invites"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple reviewer invites"
    end
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        get "/entities/#{entity.id}/reviewers/invites"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one reviewer invite
  describe "GET #reviewers/invite" do
    context "logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        get "/reviewers/invites/#{entity.reviewer_invites.first.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single reviewer invite"
    end
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        get "/reviewers/invites/#{entity.reviewer_invites.first.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Claim one admin invite
  describe "POST #reviewers/invites/claim" do
    context "not logged in" do
      let(:entity) { create(:entity) }
      before(:each) do
        invite = entity.reviewer_invites.first
        post "/reviewers/invites/claim", Oj.dump({ claim_digest: invite.claim_digest, name: "Steve", password: "secret" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single reviewer"
      it "returns the right values" do
        expect(json['account']['name']).to eq("Steve")
      end
    end
  end

end
