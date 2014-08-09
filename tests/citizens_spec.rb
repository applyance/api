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

  shared_examples_for "a single citizen" do
    it "returns the information for citizen show" do
      expect(json.keys).to contain_exactly('id', 'account', 'location', 'stage', 'phone_number', 'ratings', 'labels', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple citizens" do
    it "returns the information for citizen index" do
      expect(json.first.keys).to contain_exactly('id', 'account', 'location_id', 'stage_id', 'phone_number', 'ratings', 'label_ids', 'created_at', 'updated_at')
    end
  end

  # Retrieve one citizen
  describe "GET #citizen" do
    context "logged in as reviewer" do
      let(:citizen) { create(:citizen) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{citizen.account.api_key}"
        get "/citizens/#{citizen.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single citizen"
    end
    context "not logged in" do
      let(:citizen) { create(:citizen) }
      before(:each) do
        get "/citizens/#{citizen.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update citizen
  describe "PUT #citizen" do
    context "logged in as reviewer" do
      let(:label) { create(:label) }
      let(:citizen) { create(:citizen) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{citizen.account.api_key}"
        put "/citizens/#{citizen.id}", Oj.dump({ label_ids: [label.id] }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single citizen"
      it "returns the right value" do
        expect(json['labels'].first['id']).to eq(label.id)
      end
    end
    context "not logged in" do
      let(:label) { create(:label) }
      let(:citizen) { create(:citizen) }
      before(:each) do
        put "/citizens/#{citizen.id}", Oj.dump({ label_ids: [label.id] }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove citizen
  describe "Delete #citizen" do
    context "logged in as reviewer" do
      let(:citizen) { create(:citizen) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{citizen.account.api_key}"
        delete "/citizens/#{citizen.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:citizen) { create(:citizen) }
      before(:each) do
        delete "/citizens/#{citizen.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
