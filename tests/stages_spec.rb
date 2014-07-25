ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Stage do

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
    app.db[:stages].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single stage" do
    it "returns the information for stage show" do
      expect(json.keys).to contain_exactly('id', 'name', 'position', 'pipeline', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple stages" do
    it "returns the information for stage index" do
      expect(json.first.keys).to contain_exactly('id', 'name', 'position', 'pipeline_id', 'created_at', 'updated_at')
    end
  end

  # Create stages
  describe "POST #pipelines/stage" do
    context "logged in as reviewer" do
      let!(:stage) { create(:stage) }
      before(:each) do
        @old_position = stage.position
        header "Authorization", "ApplyanceLogin auth=#{stage.pipeline.unit.reviewers.first.account.api_key}"
        post "/pipelines/#{stage.pipeline.id}/stages", Oj.dump({ name: "Stage", position: stage.position }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single stage"
      it "returns the right value" do
        stage.reload
        expect(json['name']).to eq('Stage')
        expect(json['position']).to eq(@old_position)
        expect(stage.position).to eq(@old_position + 1)
      end
    end
    context "not logged in" do
      let!(:pipeline) { create(:pipeline) }
      before(:each) do
        post "/pipelines/#{pipeline.id}/stages", Oj.dump({ name: "Stage", position: 1 }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve stages
  describe "GET #stages" do
    context "logged in as chief" do
      let(:stage) { create(:stage) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{stage.pipeline.unit.reviewers.first.account.api_key}"
        get "/pipelines/#{stage.pipeline.id}/stages"
      end

      it_behaves_like "a retrieved object"
      it "returns the number of stages" do
        expect(json.count).to eq(1)
      end
      it_behaves_like "multiple stages"
    end
    context "not logged in" do
      let(:stage) { create(:stage) }
      before(:each) do
        get "/pipelines/#{stage.pipeline.id}/stages"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one stage
  describe "GET #stage" do
    context "logged in as reviewer" do
      let(:stage) { create(:stage) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{stage.pipeline.unit.reviewers.first.account.api_key}"
        get "/stages/#{stage.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single stage"
    end
    context "not logged in" do
      let(:stage) { create(:stage) }
      before(:each) do
        get "/stages/#{stage.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Update stage
  describe "PUT #stage" do
    context "logged in as reviewer" do
      let(:stage) { create(:stage) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{stage.pipeline.unit.reviewers.first.account.api_key}"
        put "/stages/#{stage.id}", Oj.dump({ name: "Stage 2", position: 2 }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single stage"
      it "returns the right value" do
        expect(json['name']).to eq('Stage 2')
        expect(json['position']).to eq(2)
      end
    end
    context "not logged in" do
      let(:stage) { create(:stage) }
      before(:each) do
        put "/stages/#{stage.id}", Oj.dump({ name: "Stage 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Remove stage
  describe "Delete #stage" do
    context "logged in as reviewer" do
      let(:stage) { create(:stage) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{stage.pipeline.unit.reviewers.first.account.api_key}"
        delete "/stages/#{stage.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:stage) { create(:stage) }
      before(:each) do
        delete "/stages/#{stage.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
