require 'rake'
require 'webmock/rspec'

require_relative 'support/fake_stripe'

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.disable_net_connect!(
      allow_localhost: true,
      :allow => [/maps.googleapis.com/, /amazonaws.com/]
    )

    Rake.application = Rake::Application.new
    Rake.application.rake_require '../db/seed'
    Rake.application['db:reseed'].invoke("test")
  end
  config.after(:suite) do
    Rake.application['db:empty'].invoke("test")
  end
  config.before(:each) do
    stub_request(:any, /api.stripe.com/).to_rack(Applyance::Test::FakeStripe)
  end
  config.include FactoryGirl::Syntax::Methods
end
