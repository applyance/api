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
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:admins].delete
    app.db[:admin_invites].delete
    app.db[:units].delete
    app.db[:reviewers].delete
    app.db[:reviewer_invites].delete
  end
  after(:all) do
  end

  shared_examples_for "a single reviewer invite" do
    it "returns the information for reviewer invite show" do
      expect(json.keys).to contain_exactly('id', 'unit', 'email', 'status', 'access_level', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple reviewer invites" do
    it "returns the information for reviewer invite index" do
      expect(json.first.keys).to contain_exactly('id', 'unit_id', 'email', 'status', 'access_level', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "a single reviewer" do
    it "returns the information for reviewer show" do
      expect(json.keys).to contain_exactly('id', 'account', 'unit', 'access_level', 'is_entity_admin', 'created_at', 'updated_at')
    end
  end

  # Create reviewer invite
  describe "POST #reviewer/invites" do
    context "not logged in" do
      let(:unit) { create(:unit) }
      before(:each) do
        post "/units/#{unit.id}/reviewers/invites", { email: "stjowa@gmail.com", access_level: "full" }
      end

      it_behaves_like "an unauthorized account"
    end
    context "logged in as admin" do
      let(:unit) { create(:unit) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        post "/units/#{unit.id}/reviewers/invites", { email: "stjowa@gmail.com", access_level: "full" }
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
      let(:unit) { create(:unit_with_reviewer_invite) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        get "/units/#{unit.id}/reviewers/invites"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple reviewer invites"
    end
    context "not logged in" do
      let(:unit) { create(:unit_with_reviewer_invite) }
      before(:each) do
        get "/units/#{unit.id}/reviewers/invites"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one reviewer invite
  describe "GET #reviewers/invite" do
    context "logged in" do
      let(:unit) { create(:unit_with_reviewer_invite) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        get "/reviewers/invites/#{unit.reviewer_invites.first.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single reviewer invite"
    end
    context "not logged in" do
      let(:unit) { create(:unit_with_reviewer_invite) }
      before(:each) do
        get "/reviewers/invites/#{unit.reviewer_invites.first.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Claim one admin invite
  describe "PUT #admins/invites" do
    context "not logged in" do
      let(:unit) { create(:unit_with_reviewer_invite) }
      before(:each) do
        invite = unit.reviewer_invites.first
        put "/reviewers/invites/#{invite.id}", { claim_digest: invite.claim_digest, name: "Steve", password: "secret" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single reviewer"
      it "returns the right values" do
        expect(json['account']['name']).to eq("Steve")
      end
    end
  end

end
