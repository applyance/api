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
    app.db[:entities].delete
    app.db[:blueprints].delete
    app.db[:definitions].delete
    app.db[:datums].delete
    app.db[:fields].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:spots].delete
    app.db[:applications].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single application" do
    it "returns the information for application show" do
      expect(json.keys).to contain_exactly('id', 'spots', 'entities', 'fields', 'citizen', 'digest', 'reviewers', 'submitted_at', 'last_activity_at', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple applications" do
    it "returns the information for application index" do
      expect(json.first.keys).to contain_exactly('id', 'spots', 'entities', 'citizen', 'digest', 'reviewer_ids', 'submitted_at', 'last_activity_at', 'created_at', 'updated_at')
    end
  end

  # Create application
  describe "POST #applications" do
    context "not logged in" do
      let(:definition_obj) { create(:definition, :label => "Question Label 1")}
      let(:datum_obj) { create(:datum) }
      let(:blueprint) { create(:blueprint_with_spot) }

      before(:each) do

        application_request = {
          citizen: {
            name: "Stephen Watkins",
            email: "stjowa@gmail.com",
            location: {
              address: "Testing this"
            }
          },
          spot_ids: [blueprint.spot.id],
          fields: [
            {
              datum: {
                detail: {
                  value: "Answer..."
                },
                definition: {
                  name: "Question 1",
                  label: "Question Label 1",
                  description: "Description...",
                  type: "text"
                }
              }
            },
            {
              datum: {
                definition_id: definition_obj.id,
                detail: {
                  value: "Answer 2..."
                }
              }
            },
            {
              datum: {
                id: datum_obj.id,
                detail: {
                  value: "Answer 5..."
                }
              }
            },
            {
              datum_id: datum_obj.id
            }
          ]
        }

        post "/applications", Oj.dump(application_request), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single application"
      it "returns the right value" do
        expect(json['citizen']['location']).to eq(nil)
      end
    end
  end

  # Remove application
  describe "Delete #application" do
    context "logged in as reviewer" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.entities.first.reviewers.first.account.api_key}"
        delete "/applications/#{application.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) { delete "/applications/#{application.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve applications
  describe "GET #spot/applications" do
    context "logged in as reviewer" do
      let(:application) { create(:application_with_spot) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.spots.first.entity.reviewers.first.account.api_key}"
        get "/spots/#{application.spots.first.id}/applications"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple applications"
    end
    context "not logged in" do
      let(:application) { create(:application_with_spot) }
      before(:each) do
        get "/spots/#{application.spots.first.id}/applications"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve unit applications
  describe "GET #entity/applications" do
    context "logged in as reviewer" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.entities.first.reviewers.first.account.api_key}"
        get "/entities/#{application.entities.first.id}/applications"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple applications"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) do
        get "/entities/#{application.entities.first.id}/applications"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one application
  describe "GET #application" do
    context "logged in" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.citizen.account.api_key}"
        get "/applications/#{application.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single application"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) do
        get "/applications/#{application.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
