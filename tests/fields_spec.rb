ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Field do

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
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:spots].delete
    app.db[:fields].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single field" do
    it "returns the information for field show" do
      expect(json.keys).to contain_exactly('id', 'application', 'datum', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple fields" do
    it "returns the information for field index" do
      expect(json.first.keys).to contain_exactly('id', 'application_id', 'datum_id', 'created_at', 'updated_at')
    end
  end

  # Retrieve fields
  describe "GET #fields" do
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.citizens.first.account.api_key}"
        get "/applications/#{application.id}/fields"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple fields"
    end
  end

  # Retrieve one field
  describe "GET #field" do
    let(:application) { create(:application) }
    before(:each) do
      header "Authorization", "ApplyanceLogin auth=#{application.citizens.first.account.api_key}"
      get "/fields/#{application.fields.first.id}"
    end

    it_behaves_like "a retrieved object"
    it_behaves_like "a single field"
  end

  # Create fields
  describe "POST #applications/fields" do
    context "logged in as admin" do
      let(:datum) { create(:datum) }
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.citizens.first.account.api_key}"
        post "/applications/#{application.id}/fields", Oj.dump({ datum_id: datum.id }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single field"
      it "returns the right value" do
        expect(json['datum']['id']).to eq(datum.id)
      end
    end
    context "not logged in" do
      let(:datum) { create(:datum) }
      let(:application) { create(:application) }
      before(:each) do
        post "/applications/#{application.id}/fields", Oj.dump({ datum_id: datum.id }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove field
  describe "Delete #field" do
    context "logged in as admin" do
      let(:field) { create(:field_with_application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{field.datum.profile.account.api_key}"
        delete "/fields/#{field.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:field) { create(:field_with_application) }
      before(:each) { delete "/fields/#{field.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
