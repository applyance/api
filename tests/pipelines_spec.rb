ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Pipeline do

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
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single pipeline" do
    it "returns the information for pipeline show" do
      expect(json.keys).to contain_exactly('id', 'name', 'entity', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple pipelines" do
    it "returns the information for pipeline index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'entity_id', 'created_at', 'updated_at')
    end
  end

  # Create pipelines
  describe "POST #entities/pipeline" do
    context "logged in as reviewer" do
      let!(:entity) { create(:entity) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{entity.reviewers.first.account.api_key}"
        post "/entities/#{entity.id}/pipelines", Oj.dump({ name: "Pipeline" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single pipeline"
      it "returns the right value" do
        expect(json['name']).to eq('Pipeline')
      end
    end
    context "not logged in" do
      let!(:entity) { create(:entity) }
      before(:each) do
        post "/entities/#{entity.id}/pipelines", Oj.dump({ name: "Pipeline" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve pipelines
  describe "GET #pipelines" do
    context "logged in as chief" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{pipeline.entity.reviewers.first.account.api_key}"
        get "/entities/#{pipeline.entity.id}/pipelines"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of pipelines" do
        expect(json.count).to eq(1)
      end
      it_behaves_like "multiple pipelines"
    end
    context "not logged in" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        get "/entities/#{pipeline.entity.id}/pipelines"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one pipeline
  describe "GET #pipeline" do
    context "logged in as reviewer" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{pipeline.entity.reviewers.first.account.api_key}"
        get "/pipelines/#{pipeline.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single pipeline"
    end
    context "not logged in" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        get "/pipelines/#{pipeline.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update pipeline
  describe "PUT #pipeline" do
    context "logged in as reviewer" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{pipeline.entity.reviewers.first.account.api_key}"
        put "/pipelines/#{pipeline.id}", Oj.dump({ name: "Pipeline 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single pipeline"
      it "returns the right value" do
        expect(json['name']).to eq('Pipeline 2')
      end
    end
    context "not logged in" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        put "/pipelines/#{pipeline.id}", Oj.dump({ name: "Pipeline 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove pipeline
  describe "Delete #pipeline" do
    context "logged in as reviewer" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{pipeline.entity.reviewers.first.account.api_key}"
        delete "/pipelines/#{pipeline.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:pipeline) { create(:pipeline) }
      before(:each) do
        delete "/pipelines/#{pipeline.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
