ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Datum do

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
    app.db[:datums].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:spots].delete
  end
  after(:all) do
  end

  shared_examples_for "a single datum" do
    it "returns the information for datum show" do
      expect(json.keys).to contain_exactly('id', 'profile', 'definition', 'attachments', 'detail', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple datums" do
    it "returns the information for datum index" do
      expect(json.first.keys).to contain_exactly('id', 'profile_id', 'definition', 'attachments', 'detail', 'created_at', 'updated_at')
    end
  end

  # Update datum
  describe "PUT #datum" do
    context "logged in as admin" do
      let(:datum) { create(:datum) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{datum.profile.account.api_key}"
        put "/datums/#{datum.id}", Oj.dump({ detail: "Datum Change" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single datum"
      it "returns the right value" do
        expect(json['detail']).to eq('Datum Change')
      end
    end
    context "not logged in" do
      let(:datum) { create(:datum) }
      before(:each) { put "/datums/#{datum.id}", Oj.dump({ name: "The Iron Yard" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove datum
  describe "Delete #datum" do
    context "logged in as admin" do
      let(:datum) { create(:datum) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{datum.profile.account.api_key}"
        delete "/datums/#{datum.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:datum) { create(:datum) }
      before(:each) { delete "/datums/#{datum.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one datum
  describe "GET #datum" do
    let(:datum) { create(:datum) }
    before(:each) { get "/datums/#{datum.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single datum"
  end

  # Retrieve datums
  describe "GET #datums" do
    context "not logged in" do
      let(:datum) { create(:datum) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{datum.profile.account.api_key}"
        get "/profiles/#{datum.profile.id}/datums"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple datums"
    end
  end

  # Create datum
  describe "POST #profiles/datums" do
    context "logged in as admin" do
      let(:definition) { create(:definition, :is_sensitive => true) }
      let(:profile) { create(:profile) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{profile.account.api_key}"
        post "/profiles/#{profile.id}/datums", Oj.dump({ definition_id: definition.id, detail: { value: "Detail..." } }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single datum"
      it "returns the right value" do
        expect(json['definition']['id']).to eq(definition.id)
        expect(json['detail']['value']).to eq('Detail...')
      end
    end
    context "not logged in" do
      let(:definition) { create(:definition) }
      let(:profile) { create(:profile) }
      before(:each) do
        post "/profiles/#{profile.id}/datums", Oj.dump({ definition_id: definition.id, detail: "Detail..." }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
