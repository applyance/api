module Applyance
  module Migration012
    class Util
      def self.add_feature_to_plan(plan_id, feature_id)
        Applyance::Server.db[:entity_customer_features_entity_customer_plans]
          .insert(
            :entity_customer_feature_id => feature_id,
            :entity_customer_plan_id => plan_id
          )
      end
    end
  end
end

Sequel.migration do
  up do

    puts "Creating new customer tables."

    create_table(:entity_customer_features) do
      primary_key :id
      String :name
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:entity_customer_plans) do
      primary_key :id
      String :name
      String :stripe_id
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:entity_customer_invoices) do
      primary_key :id
      foreign_key :customer_id, :entity_customers, :on_delete => :set_null
      String :stripe_invoice_id
      String :stripe_charge_id
      Integer :starting_balance
      Integer :ending_balance
      Integer :subtotal
      Integer :discount
      Integer :total
      Integer :amount_due
      TrueClass :is_attempted
      TrueClass :is_paid
      TrueClass :is_closed
      TrueClass :is_forgiven
      DateTime :period_start
      DateTime :period_end
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:entity_customer_features_entity_customer_plans) do
      foreign_key :entity_customer_feature_id, :entity_customer_features, :on_delete => :cascade
      foreign_key :entity_customer_plan_id, :entity_customer_plans, :on_delete => :cascade
    end

    alter_table(:entity_customers) do
      add_foreign_key :plan_id, :entity_customer_plans
      add_column :stripe_subscription_id, String
      add_column :subscription_status, String
      add_column :active_until, DateTime
    end

    puts "New customer tables created."

    # Create features
    puts "Creating features."
    feature_applicantList_id = Applyance::Server.db[:entity_customer_features].insert(:name => "applicantList")
    feature_applicantManagement_id = Applyance::Server.db[:entity_customer_features].insert(:name => "applicantManagement")
    feature_applicantView_id = Applyance::Server.db[:entity_customer_features].insert(:name => "applicantView")
    feature_spots_id = Applyance::Server.db[:entity_customer_features].insert(:name => "spots")
    feature_locations_id = Applyance::Server.db[:entity_customer_features].insert(:name => "locations")
    feature_questions_id = Applyance::Server.db[:entity_customer_features].insert(:name => "questions")
    feature_team_id = Applyance::Server.db[:entity_customer_features].insert(:name => "team")
    feature_labels_id = Applyance::Server.db[:entity_customer_features].insert(:name => "labels")

    # Create plans
    puts "Creating plans."
    free_plan_id = Applyance::Server.db[:entity_customer_plans].insert(:name => "Free", :stripe_id => "free", :created_at => DateTime.now)
    premium_plan_id = Applyance::Server.db[:entity_customer_plans].insert(:name => "Premium", :stripe_id => "premium", :created_at => DateTime.now)

    # Assign features to plans
    puts "Assigning features to FREE plan."
    Applyance::Migration012::Util.add_feature_to_plan(free_plan_id, feature_spots_id)
    Applyance::Migration012::Util.add_feature_to_plan(free_plan_id, feature_locations_id)
    Applyance::Migration012::Util.add_feature_to_plan(free_plan_id, feature_questions_id)
    Applyance::Migration012::Util.add_feature_to_plan(free_plan_id, feature_applicantView_id)

    puts "Assigning features to PAID plan."
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_spots_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_applicantList_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_applicantManagement_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_applicantView_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_locations_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_questions_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_team_id)
    Applyance::Migration012::Util.add_feature_to_plan(premium_plan_id, feature_labels_id)

    # Update all the stripe stuff
    Stripe.api_key = Applyance::Server.settings.stripe_secret_key
    premium_plan = Applyance::Server.db[:entity_customer_plans].where(:id => premium_plan_id).first

    # For existing CUSTOMERS, switch their plan to premium. This should kick
    # in the free trial for 30 days and invoice them after that
    puts "Making premium plan the default for existing customers."
    customer_entity_ids = []
    Applyance::Server.db[:entity_customers].each do |entity_customer|

      customer_entity_ids << entity_customer[:entity_id]

      # Get child entities for the quantity
      location_count = Applyance::Server.db[:entities].where(:parent_id => entity_customer[:entity_id]).count
      quantity = [location_count, 1].max

      # Create a premium plan on Stripe, this will kick in the free trial
      stripe_customer = Stripe::Customer.retrieve(entity_customer[:stripe_id])
      su = stripe_customer.subscriptions.create(
        :plan => premium_plan[:stripe_id],
        :quantity => quantity
      )

      Applyance::Server.db[:entity_customers]
        .where(:id => entity_customer[:id])
        .update(
          :stripe_subscription_id => su.id,
          :subscription_status => su.status,
          :active_until => Time.at(su.current_period_end).utc.to_datetime,
          :plan_id => premium_plan.id)

      puts "  Assigned [#{premium_plan[:stripe_id]}] plan to [#{entity_customer[:entity_id]}]."
    end

    # For existing entities that are root, we have to subscribe them to a plan.
    # For now, they will be assigned to the PREMIUM plan with a 30 day free trial.
    Applyance::Server.db[:entities].each do |entity|

      next unless entity[:parent_id].nil?
      next if customer_entity_ids.include?(entity[:id])

      # Get child entities for the quantity
      location_count = Applyance::Server.db[:entities].where(:parent_id => entity[:id]).count
      quantity = [location_count, 1].max

      begin
        cu = Stripe::Customer.create(
          :description => "#{entity[:name]} [#{entity[:id]}]",
          :plan => premium_plan[:stripe_id],
          :quantity => quantity
        )
      rescue => e
        puts "  Error [#{e.inspect}]"
        raise BadRequestError.new({ detail: "There was an error creating a customer with Stripe." })
      end

      subscription = cu.subscriptions.data.first

      Applyance::Server.db[:entity_customers].insert(
        :entity_id => entity[:id],
        :stripe_id => cu.id,
        :stripe_subscription_id => subscription.id,
        :subscription_status => subscription.status,
        :active_until => Time.at(subscription.current_period_end).utc.to_datetime,
        :plan_id => premium_plan[:id],
        :created_at => DateTime.now)

      puts "  Assigned [#{premium_plan[:stripe_id]}] plan to [#{entity[:name]}]."
    end

  end
  down do
    alter_table(:entity_customers) do
      drop_foreign_key :plan_id
      drop_column :stripe_subscription_id
      drop_column :active_until
      drop_column :subscription_status
    end

    drop_table(
      :entity_customer_invoices,
      :entity_customer_features_entity_customer_plans,
      :entity_customer_features,
      :entity_customer_plans)
  end
end
