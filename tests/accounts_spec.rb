ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Account do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:domains].delete
    app.db[:entities].delete
    app.db[:reviewers].delete
  end
  after(:all) do
  end

  def chief_auth
    header "Authorization", "ApplyanceLogin auth=#{chief.api_key}"
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single account" do
    it "returns the information for account show" do
      expect(json.keys).to contain_exactly('id', 'name', 'first_name', 'last_name', 'initials', 'email', 'phone_number', 'avatar', 'is_verified', 'roles', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "a single me" do
    it "returns the information for me show" do
      expect(json.keys).to contain_exactly('account', 'citizens', 'reviewers')
    end
  end

  # Authenticate into account
  describe "POST #accounts/auth" do
    context "not logged in" do
      let(:reviewer) { create(:reviewer) }
      before(:each) do
        post "/accounts/auth", Oj.dump({ email: "#{reviewer.account.email}", password: "test" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single me"
      it "contains authorization header" do
        expect(last_response.headers['Authorization']).to eq("ApplyanceLogin auth=#{reviewer.account.api_key}")
      end
    end
  end

  # Get me
  describe "GET #accounts/me" do
    context "not logged in" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        get "/accounts/me"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single me"
    end
  end

  # Retrieve one account
  describe "GET #account" do
    let(:account) { create(:account) }
    before(:each) do
      account_auth
      get "/accounts/#{account.id}"
    end

    it_behaves_like "a retrieved object"
    it_behaves_like "a single account"
  end

  # Update account
  describe "PUT #account" do
    context "logged in as chief" do
      let(:account) { create(:chief_account) }
      before(:each) do
        account_auth
        put "/accounts/#{account.id}", Oj.dump({ name: "Steve 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single account"
      it "returns the updated values" do
        expect(json['name']).to eq('Steve 2')
        expect(json['email']).to eq(account.email)
      end
    end
    context "logged in as reviewer" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        put "/accounts/#{account.id}", Oj.dump({ name: "Steve 2" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single account"
      it "returns the updated values" do
        expect(json['name']).to eq('Steve 2')
        expect(json['email']).to eq(account.email)
      end
    end
    context "not logged in" do
      let(:account) { create(:account) }
      before(:each) { put "/accounts/#{account.id}", Oj.dump({ name: "Steve 2" }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "an unauthorized account"
    end
  end

  describe "PUT #account/password" do
    context "no old password" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        put "/accounts/#{account.id}", Oj.dump({ new_password: "testing" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an invalid request"
    end
    context "with password" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        put "/accounts/#{account.id}", Oj.dump({ password: "test", new_password: "testing" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single account"
      it "returns the updated password" do
        expect(json['name']).to eq(account.name)
        expect(json['email']).to eq(account.email)
        expect(BCrypt::Password.new(Applyance::Account.first(:id => account.id).password_hash)).to eq("testing")
      end
    end
  end

  describe "PUT #account/email" do
    context "no old password" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        put "/accounts/#{account.id}", Oj.dump({ email: "new@gmail.com" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "an invalid request"
    end
    context "with password" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        put "/accounts/#{account.id}", Oj.dump({ password: "test", email: "new2@gmail.com" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single account"
      it "returns the updated password" do
        expect(json['name']).to eq(account.name)
        expect(json['email']).to eq("new2@gmail.com")
      end
    end
  end

  # Remove account
  describe "Delete #account" do
    context "logged in as chief" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        delete "/accounts/#{account.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "logged in as reviewer" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        account_auth
        delete "/accounts/#{account.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:account) { create(:reviewer_account) }
      before(:each) { delete "/accounts/#{account.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Reset Password
  describe "POST #account/password/reset" do
    context "not logged in" do
      let(:account) { create(:reviewer_account) }
      before(:each) { post "/accounts/passwords/reset", Oj.dump({ email: account.email }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "a retrieved object"
      it_behaves_like "an empty response"
      it "created the reset digest" do
        _account = Applyance::Account.first(:id => account.id)
        expect(_account.reset_digest).not_to be_empty
      end
    end
  end

  # Set Password
  describe "POST #account/password/set" do
    context "not logged in" do
      let(:account) { create(:reviewer_account) }
      before(:each) do
        post "/accounts/passwords/reset", Oj.dump({ email: account.email }), { "CONTENT_TYPE" => "application/json" }
        account.reload
        post "/accounts/passwords/set", Oj.dump({ reset_digest: account.reset_digest, new_password: "test4" }), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a retrieved object"
      it "updated the password" do
        _account = Applyance::Account.first(:id => account.id)
        expect(BCrypt::Password.new(_account.password_hash)).to eq("test4")
      end
    end
  end

  # Verify email
  describe "POST #accounts/verify" do
    context "not logged in" do
      let(:account) { create(:reviewer_account) }
      before(:each) { post "/accounts/verify", Oj.dump({ verify_digest: account.verify_digest }), { "CONTENT_TYPE" => "application/json" } }

      it_behaves_like "a retrieved object"
      it "verified the account" do
        expect(json['is_verified']).to eq(true)
      end
    end
  end

end
