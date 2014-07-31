ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Segment do

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
    app.db[:segments].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single segment" do
    it "returns the information for segment show" do
      expect(json.keys).to contain_exactly('id', 'reviewer', 'name', 'dsl', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple segments" do
    it "returns the information for segment index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'dsl', 'reviewer_id', 'created_at', 'updated_at')
    end
  end

  # Create segments
  describe "POST #reviewer/segments" do
    context "logged in as reviewer" do
      let!(:reviewer) { create(:reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{reviewer.account.api_key}"
        post "/reviewers/#{reviewer.id}/segments", Oj.dump({ name: "Segment", dsl: "stage=1,2,3" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single segment"
      it "returns the right value" do
        expect(json['name']).to eq('Segment')
      end
    end
    context "not logged in" do
      let!(:reviewer) { create(:reviewer) }
      before(:each) do
        post "/reviewers/#{reviewer.id}/segments", Oj.dump({ name: "Segment", dsl: "stage=1,2,3" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve segments
  describe "GET #segments" do
    context "logged in as chief" do
      let(:segment) { create(:segment) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{segment.reviewer.account.api_key}"
        get "/reviewers/#{segment.reviewer.id}/segments"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of segments" do
        expect(json.count).to eq(1)
      end
      it_behaves_like "multiple segments"
    end
    context "not logged in" do
      let(:segment) { create(:segment) }
      before(:each) do
        get "/reviewers/#{segment.reviewer.id}/segments"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one segment
  describe "GET #segment" do
    context "logged in as reviewer" do
      let(:segment) { create(:segment) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{segment.reviewer.account.api_key}"
        get "/segments/#{segment.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single segment"
    end
    context "not logged in" do
      let(:segment) { create(:segment) }
      before(:each) do
        get "/segments/#{segment.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update segment
  describe "PUT #segment" do
    context "logged in as reviewer" do
      let(:segment) { create(:segment) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{segment.reviewer.account.api_key}"
        put "/segments/#{segment.id}", Oj.dump({ name: "Segment 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single segment"
      it "returns the right value" do
        expect(json['name']).to eq('Segment 2')
      end
    end
    context "not logged in" do
      let(:segment) { create(:segment) }
      before(:each) do
        put "/segments/#{segment.id}", Oj.dump({ name: "Segment 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove segment
  describe "Delete #segment" do
    context "logged in as reviewer" do
      let(:segment) { create(:segment) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{segment.reviewer.account.api_key}"
        delete "/segments/#{segment.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:segment) { create(:segment) }
      before(:each) do
        delete "/segments/#{segment.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
