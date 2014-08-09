ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Attachment do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:entities].delete
    app.db[:domains].delete
    app.db[:attachments].delete
  end
  after(:all) do
  end

  # Create attachments
  describe "PUT #attachment" do
    context "logged in" do
      let(:account) { create(:citizen_account) }
      before(:each) do
        account_auth
        request = {
          avatar: {
            name: "avatar.png",
            token: "4cb812b99f34fa3de0889a5ccd2c295d"
          }
        }
        put "/accounts/#{account.id}", Oj.dump(request), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it "returns the right value" do
        expect(json['avatar'].keys).to contain_exactly('id', 'token', 'name', 'url', 'content_type', 'byte_size', 'created_at', 'updated_at')
        expect(json['avatar']['name']).to eq('avatar.png')
      end
    end
  end

end
