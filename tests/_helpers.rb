module Applyance
  module Test
    module Helpers
      def json
        @json ||= Oj.load(last_response.body)
      end

      def objectify
        @objectify ||= Oj.load(last_response.body, :symbol_keys => true)
      end

      def app
        @app ||= Applyance::Server
      end

      def account_auth
        header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
      end

      shared_examples_for "a created object" do
        it "returns the right status code" do
          puts "------------------------------"
          puts last_response.body
          puts "------------------------------"
          expect(last_response.status).to eq(201)
        end
      end

      shared_examples_for "a retrieved object" do
        it "returns the right status code" do
          puts "------------------------------"
          puts last_response.body
          puts "------------------------------"
          expect(last_response.status).to eq(200)
        end
      end

      shared_examples_for "a deleted object" do
        it "returns the right status code" do
          puts "------------------------------"
          puts last_response.body
          puts "------------------------------"
          expect(last_response.status).to eq(204)
        end
      end

      shared_examples_for "an unauthorized account" do
        it "returns the right status code" do
          puts "------------------------------"
          puts last_response.body
          puts "------------------------------"
          expect(last_response.status).to eq(401)
        end
      end

      shared_examples_for "an invalid request" do
        it "returns the right status code" do
          expect(last_response.status).to eq(400)
        end
      end

      shared_examples_for "an empty response" do
        it "returns an empty response" do
          expect(last_response.body).to be_empty
        end
      end

    end
  end
end
