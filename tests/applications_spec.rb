ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Application do

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
    app.db[:spots].delete
    app.db[:applications].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single spot" do
    it "returns the information for spot show" do
      expect(json.keys).to contain_exactly('id', 'unit', 'name', 'detail', 'status', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple spots" do
    it "returns the information for spot index" do
      expect(json.first.keys).to contain_exactly('id', 'unit_id', 'name', 'detail', 'status', 'created_at', 'updated_at')
    end
  end

  # Create units
  describe "POST #units" do
    context "logged in as admin" do
      let(:unit) { create(:unit) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{unit.reviewers.first.account.api_key}"
        post "/units/#{unit.id}/spots", { name: "Spot", detail: "Detail...", status: "open" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single spot"
      it "returns the right value" do
        expect(json['name']).to eq('Spot')
        expect(json['detail']).to eq('Detail...')
      end
    end
    context "not logged in" do
      let(:unit) { create(:unit) }
      before(:each) { post "/units/#{unit.id}/spots", { name: "Spot", detail: "Detail...", status: "open" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve spots
  describe "GET #spots" do
    context "not logged in" do
      let(:spot) { create(:spot) }
      before(:each) do
        get "/units/#{spot.unit.id}/spots"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple spots"
    end
  end

  # Retrieve one spot
  describe "GET #spot" do
    let(:spot) { create(:spot) }
    before(:each) { get "/spots/#{spot.id}" }

    it_behaves_like "a retrieved object"
    it_behaves_like "a single spot"
  end

  # Update spot
  describe "PUT #spot" do
    context "logged in as admin" do
      let(:spot) { create(:spot) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{spot.unit.reviewers.first.account.api_key}"
        put "/spots/#{spot.id}", { name: "Spot Change" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single spot"
      it "returns the right value" do
        expect(json['name']).to eq('Spot Change')
      end
    end
    context "not logged in" do
      let(:spot) { create(:spot) }
      before(:each) { put "/spots/#{spot.id}", { name: "The Iron Yard" } }

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove spot
  describe "Delete #spot" do
    context "logged in as admin" do
      let(:spot) { create(:spot) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{spot.unit.reviewers.first.account.api_key}"
        delete "/spots/#{spot.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:spot) { create(:spot) }
      before(:each) { delete "/spots/#{spot.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

end
