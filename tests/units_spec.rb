ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Unit do

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
    app.db[:units].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single unit" do
    it "returns the information for unit show" do
      expect(json.keys).to contain_exactly('id', 'name', 'entity', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple units" do
    it "returns the information for unit index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'entity_id', 'created_at', 'updated_at')
    end
  end

  # Create entities
  describe "POST #units" do
    context "logged in as admin" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.admins.first.account.api_key}"
        post "/entities/#{entity.id}/units", Oj.dump({ name: "Building 1" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single unit"
      it "returns the right value" do
        expect(json['name']).to eq('Building 1')
      end
    end
    context "not logged in" do
      let(:entity) { create(:entity_with_admin) }
      before(:each) { post "/entities/#{entity.id}/units", Oj.dump({ name: "Building 1" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve units
  describe "GET #units" do
    context "logged in as admin" do
      let(:unit) { create(:unit) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.entity.admins.first.account.api_key}"
        get "/entities/#{unit.entity.id}/units"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple units"
    end
    context "not logged in" do
      let(:unit) { create(:unit) }
      before(:each) do
        get "/entities/#{unit.entity.id}/units"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one unit
  describe "GET #unit" do
    let(:unit) { create(:unit) }
    before(:each) { get "/units/#{unit.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single unit"
  end

  # Update unit
  describe "PUT #unit" do
    context "logged in as admin" do
      let(:unit) { create(:unit_with_reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.entity.admins.first.account.api_key}"
        put "/units/#{unit.id}", Oj.dump({ name: "Retail 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single unit"
      it "returns the right value" do
        expect(json['name']).to eq('Retail 2')
      end
    end
    context "not logged in" do
      let(:unit) { create(:unit) }
      before(:each) { put "/units/#{unit.id}", Oj.dump({ name: "The Iron Yard" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove unit
  describe "Delete #unit" do
    context "logged in as admin" do
      let(:unit) { create(:unit_with_reviewer) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        delete "/units/#{unit.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:unit) { create(:unit_with_reviewer) }
      before(:each) { delete "/units/#{unit.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
