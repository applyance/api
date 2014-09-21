ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Routing::Webhooks do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:entity_customers].delete
    app.db[:entity_customer_invoices].delete
    app.db[:entities].delete
  end
  after(:all) do
  end

  # customer.card.updated
  describe "POST #webhooks/stripe . customer.card.updated" do
    let!(:customer) { create(:entity_customer) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "customer.card.updated",
        "data"=> {
          "object"=> {
            "id"=> "card_14eU9X2gRsEqJefMl0kGpfUA",
            "object"=> "card",
            "last4"=> "4243",
            "brand"=> "Visa",
            "funding"=> "credit",
            "exp_month"=> 8,
            "exp_year"=> 2015,
            "fingerprint"=> "jIpQsLSeZhWYSzje",
            "country"=> "US",
            "name"=> "Jane Austen",
            "address_line1"=> nil,
            "address_line2"=> nil,
            "address_city"=> nil,
            "address_state"=> nil,
            "address_zip"=> nil,
            "address_country"=> nil,
            "cvc_check"=> nil,
            "address_line1_check"=> nil,
            "address_zip_check"=> nil,
            "customer"=> customer.stripe_id
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => customer.id)
      expect(last_response.status).to eq(200)
      expect(customer_saved.last4).to eq("4243")
      expect(customer_saved.exp_month).to eq("8")
      expect(customer_saved.exp_year).to eq("2015")
    end
  end

  # customer.card.deleted
  describe "POST #webhooks/stripe . customer.card.deleted" do
    let!(:customer) { create(:entity_customer, :last4 => "1234") }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "customer.card.deleted",
        "data"=> {
          "object"=> {
            "id"=> "card_14eU9X2gRsEqJefMl0kGpfUA",
            "object"=> "card",
            "last4"=> "4243",
            "brand"=> "Visa",
            "funding"=> "credit",
            "exp_month"=> 8,
            "exp_year"=> 2015,
            "fingerprint"=> "jIpQsLSeZhWYSzje",
            "country"=> "US",
            "name"=> "Jane Austen",
            "address_line1"=> nil,
            "address_line2"=> nil,
            "address_city"=> nil,
            "address_state"=> nil,
            "address_zip"=> nil,
            "address_country"=> nil,
            "cvc_check"=> nil,
            "address_line1_check"=> nil,
            "address_zip_check"=> nil,
            "customer"=> customer.stripe_id
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => customer.id)
      expect(last_response.status).to eq(200)
      expect(customer_saved.last4).to eq(nil)
      expect(customer_saved.exp_month).to eq(nil)
      expect(customer_saved.exp_year).to eq(nil)
    end
  end

  # customer.subscription.created
  describe "POST #webhooks/stripe . customer.subscription.created" do
    let!(:customer) { create(:entity_customer) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "customer.subscription.created",
        "data"=> {
          "object"=> {
            "id" => "sub_4o6MtmIDnASfgy",
            "plan" => {
              "interval" => "month",
              "name" => "Monthly",
              "created" => 1404363125,
              "amount" => 20000,
              "currency" => "usd",
              "id" => "premium",
              "object" => "plan",
              "livemode" => false,
              "interval_count" => 1,
              "trial_period_days" => nil,
              "metadata" => {
              },
              "statement_description" => nil
            },
            "object" => "subscription",
            "start" => 1411143755,
            "status" => "active",
            "customer" => customer.stripe_id,
            "cancel_at_period_end" => false,
            "current_period_start" => 1411143755,
            "current_period_end" => 1413735755,
            "ended_at" => nil,
            "trial_start" => nil,
            "trial_end" => nil,
            "canceled_at" => nil,
            "quantity" => 1,
            "application_fee_percent" => nil,
            "discount" => nil,
            "metadata" => {
            }
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => customer.id)
      plan_saved = customer_saved.plan

      expect(last_response.status).to eq(200)
      expect(plan_saved.stripe_id).to eq("premium")
      expect(customer_saved.subscription_status).to eq("active")
      expect(customer_saved.stripe_subscription_id).to eq("sub_4o6MtmIDnASfgy")
      expect(customer_saved.active_until.to_time.utc.to_i).to eq(1413735755)
    end
  end

  # customer.subscription.updated
  describe "POST #webhooks/stripe . customer.subscription.updated" do
    let!(:entity) { create(:entity) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "customer.subscription.updated",
        "data"=> {
          "object"=> {
            "id" => entity.customer.stripe_subscription_id,
            "plan" => {
              "interval" => "month",
              "name" => "Monthly",
              "created" => 1404363125,
              "amount" => 20000,
              "currency" => "usd",
              "id" => "premium",
              "object" => "plan",
              "livemode" => false,
              "interval_count" => 1,
              "trial_period_days" => nil,
              "metadata" => {
              },
              "statement_description" => nil
            },
            "object" => "subscription",
            "start" => 1411143755,
            "status" => "unpaid",
            "customer" => entity.customer.stripe_id,
            "cancel_at_period_end" => false,
            "current_period_start" => 1411143755,
            "current_period_end" => 1413735759,
            "ended_at" => nil,
            "trial_start" => nil,
            "trial_end" => nil,
            "canceled_at" => nil,
            "quantity" => 1,
            "application_fee_percent" => nil,
            "discount" => nil,
            "metadata" => {
            }
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => entity.customer.id)
      plan_saved = customer_saved.plan

      expect(last_response.status).to eq(200)
      expect(plan_saved.stripe_id).to eq("premium")
      expect(customer_saved.subscription_status).to eq("unpaid")
      expect(customer_saved.active_until.to_time.utc.to_i).to eq(1413735759)
    end
  end

  # customer.subscription.deleted
  describe "POST #webhooks/stripe . customer.subscription.deleted" do
    let!(:entity) { create(:entity) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "customer.subscription.deleted",
        "data"=> {
          "object"=> {
            "id" => entity.customer.stripe_subscription_id,
            "plan" => {
              "interval" => "month",
              "name" => "Monthly",
              "created" => 1404363125,
              "amount" => 20000,
              "currency" => "usd",
              "id" => "premium",
              "object" => "plan",
              "livemode" => false,
              "interval_count" => 1,
              "trial_period_days" => nil,
              "metadata" => {
              },
              "statement_description" => nil
            },
            "object" => "subscription",
            "start" => 1411143755,
            "status" => "active",
            "customer" => entity.customer.stripe_id,
            "cancel_at_period_end" => false,
            "current_period_start" => 1411143755,
            "current_period_end" => 1413735759,
            "ended_at" => nil,
            "trial_start" => nil,
            "trial_end" => nil,
            "canceled_at" => nil,
            "quantity" => 1,
            "application_fee_percent" => nil,
            "discount" => nil,
            "metadata" => {
            }
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => entity.customer.id)
      plan_saved = customer_saved.plan

      expect(last_response.status).to eq(200)
      expect(customer_saved.subscription_status).to eq("active")
      expect(plan_saved.stripe_id).to eq("free")
    end
  end

  # invoice.created
  describe "POST #webhooks/stripe . invoice.created" do
    let!(:customer) { create(:entity_customer) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "invoice.created",
        "data"=> {
          "object"=> {
            "date" => 1411143755,
            "id" => "in_14eU9X2gRsEqJefMR0zg94ms",
            "period_start" => 1411143755,
            "period_end" => 1411143755,
            "lines" => {
              "data" => [
                {
                  "id" => "ii_14eU9X2gRsEqJefMah0DmsgM",
                  "object" => "line_item",
                  "type" => "invoiceitem",
                  "livemode" => false,
                  "amount" => 0,
                  "currency" => "usd",
                  "proration" => false,
                  "period" => {
                    "start" => 1411143755,
                    "end" => 1411143755
                  },
                  "quantity" => nil,
                  "plan" => nil,
                  "description" => "My First Invoice Item (created for API docs)",
                  "metadata" => {
                  }
                }
              ],
              "count" => 1,
              "object" => "list",
              "url" => "/v1/invoices/in_14eU9X2gRsEqJefMR0zg94ms/lines"
            },
            "subtotal" => 1400,
            "total" => 1200,
            "customer" => customer.stripe_id,
            "object" => "invoice",
            "attempted" => false,
            "closed" => false,
            "forgiven" => false,
            "paid" => false,
            "livemode" => false,
            "attempt_count" => 0,
            "amount_due" => 1200,
            "currency" => "usd",
            "starting_balance" => 0,
            "ending_balance" => nil,
            "next_payment_attempt" => 1411147355,
            "webhooks_delivered_at" => nil,
            "charge" => nil,
            "discount" => nil,
            "application_fee" => nil,
            "subscription" => nil,
            "metadata" => {
            },
            "statement_description" => nil,
            "description" => nil
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => customer.id)
      invoice = customer_saved.invoices.first

      expect(last_response.status).to eq(200)
      expect(invoice.amount_due).to eq(1200)
      expect(invoice.discount).to eq(200)
    end
  end

  # invoice.updated
  describe "POST #webhooks/stripe . invoice.updated" do
    let!(:invoice) { create(:entity_customer_invoice, :stripe_invoice_id => "in_14eU9X2gRsEqJefMR0zg94ms") }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "invoice.updated",
        "data"=> {
          "object"=> {
            "date" => 1411143755,
            "id" => invoice.stripe_invoice_id,
            "period_start" => 1411143755,
            "period_end" => 1411143755,
            "lines" => {
              "data" => [
                {
                  "id" => "ii_14eU9X2gRsEqJefMah0DmsgM",
                  "object" => "line_item",
                  "type" => "invoiceitem",
                  "livemode" => false,
                  "amount" => 0,
                  "currency" => "usd",
                  "proration" => false,
                  "period" => {
                    "start" => 1411143755,
                    "end" => 1411143755
                  },
                  "quantity" => nil,
                  "plan" => nil,
                  "description" => "My First Invoice Item (created for API docs)",
                  "metadata" => {
                  }
                }
              ],
              "count" => 1,
              "object" => "list",
              "url" => "/v1/invoices/in_14eU9X2gRsEqJefMR0zg94ms/lines"
            },
            "subtotal" => 1700,
            "total" => 1400,
            "customer" => invoice.customer.stripe_id,
            "object" => "invoice",
            "attempted" => false,
            "closed" => false,
            "forgiven" => false,
            "paid" => false,
            "livemode" => false,
            "attempt_count" => 0,
            "amount_due" => 1400,
            "currency" => "usd",
            "starting_balance" => 0,
            "ending_balance" => nil,
            "next_payment_attempt" => 1411147355,
            "webhooks_delivered_at" => nil,
            "charge" => nil,
            "discount" => nil,
            "application_fee" => nil,
            "subscription" => nil,
            "metadata" => {
            },
            "statement_description" => nil,
            "description" => nil
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => invoice.customer.id)
      invoice = customer_saved.invoices.first

      expect(last_response.status).to eq(200)
      expect(invoice.amount_due).to eq(1400)
      expect(invoice.discount).to eq(300)
    end
  end

  # invoice.payment_succeeded
  describe "POST #webhooks/stripe . invoice.payment_succeeded" do
    let!(:entity) { create(:entity) }
    let!(:invoice) { create(:entity_customer_invoice, :stripe_invoice_id => "in_14eU9X2gRsEqJefMR0zg94ms", :customer => entity.customer) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "invoice.payment_succeeded",
        "data"=> {
          "object"=> {
            "date" => 1411143755,
            "id" => invoice.stripe_invoice_id,
            "period_start" => 1411143755,
            "period_end" => 1411143755,
            "lines" => {
              "data" => [
                {
                  "id" => "ii_14eU9X2gRsEqJefMah0DmsgM",
                  "object" => "line_item",
                  "type" => "invoiceitem",
                  "livemode" => false,
                  "amount" => 0,
                  "currency" => "usd",
                  "proration" => false,
                  "period" => {
                    "start" => 1411143755,
                    "end" => 1411143755
                  },
                  "quantity" => nil,
                  "plan" => nil,
                  "description" => "My First Invoice Item (created for API docs)",
                  "metadata" => {
                  }
                }
              ],
              "count" => 1,
              "object" => "list",
              "url" => "/v1/invoices/in_14eU9X2gRsEqJefMR0zg94ms/lines"
            },
            "subtotal" => 1700,
            "total" => 1400,
            "customer" => invoice.customer.stripe_id,
            "object" => "invoice",
            "attempted" => false,
            "closed" => false,
            "forgiven" => false,
            "paid" => false,
            "livemode" => false,
            "attempt_count" => 0,
            "amount_due" => 1400,
            "currency" => "usd",
            "starting_balance" => 0,
            "ending_balance" => nil,
            "next_payment_attempt" => 1411147355,
            "webhooks_delivered_at" => nil,
            "charge" => nil,
            "discount" => nil,
            "application_fee" => nil,
            "subscription" => nil,
            "metadata" => {
            },
            "statement_description" => nil,
            "description" => nil
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      customer_saved = Applyance::EntityCustomer.first(:id => invoice.customer.id)
      invoice = customer_saved.invoices.first

      expect(last_response.status).to eq(200)
    end
  end

  # customer.subscription.trial_will_end
  describe "POST #webhooks/stripe . customer.subscription.trial_will_end" do
    let!(:entity) { create(:entity) }
    before(:each) do
      event = {
        "id"=> "evt_14eU9Y2gRsEqJefM9VKu4srr",
        "created"=> 1411143756,
        "livemode"=> false,
        "type"=> "customer.subscription.trial_will_end",
        "data"=> {
          "object"=> {
            "id" => entity.customer.stripe_subscription_id,
            "plan" => {
              "interval" => "month",
              "name" => "Monthly",
              "created" => 1404363125,
              "amount" => 20000,
              "currency" => "usd",
              "id" => "premium",
              "object" => "plan",
              "livemode" => false,
              "interval_count" => 1,
              "trial_period_days" => nil,
              "metadata" => {
              },
              "statement_description" => nil
            },
            "object" => "subscription",
            "start" => 1411143755,
            "status" => "active",
            "customer" => entity.customer.stripe_id,
            "cancel_at_period_end" => false,
            "current_period_start" => 1411143755,
            "current_period_end" => 1413735759,
            "ended_at" => nil,
            "trial_start" => nil,
            "trial_end" => nil,
            "canceled_at" => nil,
            "quantity" => 1,
            "application_fee_percent" => nil,
            "discount" => nil,
            "metadata" => {
            }
          }
        },
        "object"=> "event",
        "pending_webhooks"=> 0,
        "request"=> nil
      }
      post "/webhooks/stripe", JSON.dump(event), { "CONTENT_TYPE" => "application/json" }
    end

    it "returns correctly" do
      expect(last_response.status).to eq(200)
    end
  end

end
