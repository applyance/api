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

      shared_examples_for "a created object" do
        it "returns the right status code" do
          expect(last_response.status).to eq(201)
        end
      end

      shared_examples_for "a retrieved object" do
        it "returns the right status code" do
          expect(last_response.status).to eq(200)
        end
      end

      shared_examples_for "a deleted object" do
        it "returns the right status code" do
          expect(last_response.status).to eq(204)
        end
      end

      shared_examples_for "an unauthorized account" do
        it "returns the right status code" do
          expect(last_response.status).to eq(401)
        end
      end

    end
  end
end
