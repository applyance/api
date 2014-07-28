ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::AdminInvite do

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
    app.db[:admin_invites].delete
  end
  after(:all) do
  end

  shared_examples_for "a single admin invite" do
    it "returns the information for admin invite show" do
      expect(json.keys).to contain_exactly('id', 'entity', 'email', 'status', 'access_level', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple admin invites" do
    it "returns the information for admin invite index" do
      expect(json.first.keys).to contain_exactly('id', 'entity_id', 'email', 'status', 'access_level', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "a single admin" do
    it "returns the information for admin show" do
      expect(json.keys).to contain_exactly('id', 'account', 'entity', 'access_level', 'created_at', 'updated_at')
    end
  end

  # Create admin invites
  describe "POST #admin_invites" do
    context "not logged in" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        post "/entities/#{entity.id}/admins/invites", Oj.dump({ email: "stjowa@gmail.com", access_level: "limited" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
    context "logged in as admin" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        post "/entities/#{entity.id}/admins/invites", Oj.dump({ email: "stjowa@gmail.com", access_level: "limited" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single admin invite"
      it "returns the right value" do
        expect(json['email']).to eq('stjowa@gmail.com')
      end
    end
  end

  # Retrieve admin invites for entity
  describe "GET #admin_invites" do
    context "logged in" do
      let(:entity) { create(:entity_with_admin_invite) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        get "/entities/#{entity.id}/admins/invites"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple admin invites"
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_admin_invite) }
      before(:each) do
        get "/entities/#{entity.id}/admins/invites"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one admin invite
  describe "GET #admin_invite" do
    context "logged in" do
      let(:entity) { create(:entity_with_admin_invite) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        get "/admins/invites/#{entity.admin_invites.first.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single admin invite"
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_admin_invite) }
      before(:each) do
        get "/admins/invites/#{entity.admin_invites.first.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Claim one admin invite
  describe "POST #admins/invites/claim" do
    context "not logged in" do
      let(:entity) { create(:entity_with_admin_invite) }
      before(:each) do
        invite = entity.admin_invites.first
        post "/admins/invites/claim", Oj.dump({ claim_digest: invite.claim_digest, name: "Steve", password: "secret" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single admin"
      it "returns the right values" do
        expect(json['account']['name']).to eq("Steve")
      end
    end
  end

end
