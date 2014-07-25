ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Label do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:admins].delete
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:units].delete
    app.db[:pipelines].delete
    app.db[:labels].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single label" do
    it "returns the information for label show" do
      expect(json.keys).to contain_exactly('id', 'name', 'color', 'unit', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple labels" do
    it "returns the information for label index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'color', 'unit_id', 'created_at', 'updated_at')
    end
  end

  # Create labels
  describe "POST #units/label" do
    context "logged in as reviewer" do
      let!(:unit) { create(:unit_with_reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        post "/units/#{unit.id}/labels", Oj.dump({ name: "Label", color: "990000" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single label"
      it "returns the right value" do
        expect(json['name']).to eq('Label')
      end
    end
    context "not logged in" do
      let!(:unit) { create(:unit) }
      before(:each) do
        post "/units/#{unit.id}/labels", Oj.dump({ name: "Label" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve labels
  describe "GET #labels" do
    context "logged in as chief" do
      let(:label) { create(:label) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{label.unit.reviewers.first.account.api_key}"
        get "/units/#{label.unit.id}/labels"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of labels" do
        expect(json.count).to eq(1)
      end
      it_behaves_like "multiple labels"
    end
    context "not logged in" do
      let(:label) { create(:label) }
      before(:each) do
        get "/units/#{label.unit.id}/labels"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one label
  describe "GET #label" do
    context "logged in as reviewer" do
      let(:label) { create(:label) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{label.unit.reviewers.first.account.api_key}"
        get "/labels/#{label.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single label"
    end
    context "not logged in" do
      let(:label) { create(:label) }
      before(:each) do
        get "/labels/#{label.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update label
  describe "PUT #label" do
    context "logged in as reviewer" do
      let(:label) { create(:label) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{label.unit.reviewers.first.account.api_key}"
        put "/labels/#{label.id}", Oj.dump({ name: "Label 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single label"
      it "returns the right value" do
        expect(json['name']).to eq('Label 2')
      end
    end
    context "not logged in" do
      let(:label) { create(:label) }
      before(:each) do
        put "/labels/#{label.id}", Oj.dump({ name: "Label 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove label
  describe "Delete #label" do
    context "logged in as reviewer" do
      let(:label) { create(:label) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{label.unit.reviewers.first.account.api_key}"
        delete "/labels/#{label.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:label) { create(:label) }
      before(:each) do
        delete "/labels/#{label.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
