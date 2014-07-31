ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Note do

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
    app.db[:notes].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single note" do
    it "returns the information for note show" do
      expect(json.keys).to contain_exactly('id', 'note', 'application', 'reviewer', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple notes" do
    it "returns the information for note index" do
      expect(json.first.keys).to contain_exactly('id', 'note', 'application_id', 'reviewer_id', 'created_at', 'updated_at')
    end
  end

  # Create notes
  describe "POST #reviewers/note" do
    context "logged in as reviewer" do
      let!(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.spots.first.entity.reviewers.first.account.api_key}"
        post "/reviewers/#{application.spots.first.entity.reviewers.first.id}/notes", Oj.dump({ note: "Detail...", application_id: application.id }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single note"
      it "returns the right value" do
        expect(json['note']).to eq("Detail...")
      end
    end
    context "not logged in" do
      let!(:application) { create(:application) }
      before(:each) do
        post "/reviewers/#{application.spots.first.entity.reviewers.first.id}/notes", Oj.dump({ note: "Detail...", application_id: application.id }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve notes
  describe "GET #notes" do
    context "logged in as chief" do
      let(:note) { create(:note) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{note.reviewer.account.api_key}"
        get "/applications/#{note.application.id}/notes"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of notes" do
        expect(json.count).to eq(1)
      end
      it_behaves_like "multiple notes"
    end
    context "not logged in" do
      let(:note) { create(:note) }
      before(:each) do
        get "/applications/#{note.application.id}/notes"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one note
  describe "GET #note" do
    context "logged in as reviewer" do
      let(:note) { create(:note) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{note.reviewer.account.api_key}"
        get "/notes/#{note.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single note"
    end
    context "not logged in" do
      let(:note) { create(:note) }
      before(:each) do
        get "/notes/#{note.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update note
  describe "PUT #note" do
    context "logged in as reviewer" do
      let(:note) { create(:note) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{note.reviewer.account.api_key}"
        put "/notes/#{note.id}", Oj.dump({ note: "Detail 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single note"
      it "returns the right value" do
        expect(json['note']).to eq("Detail 2")
      end
    end
    context "not logged in" do
      let(:note) { create(:note) }
      before(:each) do
        put "/notes/#{note.id}", Oj.dump({ note: "Detail 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove note
  describe "Delete #note" do
    context "logged in as reviewer" do
      let(:note) { create(:note) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{note.reviewer.account.api_key}"
        delete "/notes/#{note.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:note) { create(:note) }
      before(:each) do
        delete "/notes/#{note.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
