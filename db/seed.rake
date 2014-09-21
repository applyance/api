module Applyance
  module DB
    module Seed
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
end

namespace :bundler do
  task :setup do
    require 'rubygems'
    require 'bundler/setup'
  end
end

task :environment, [:env] => 'bundler:setup' do |cmd, args|
  ENV["RACK_ENV"] = args[:env] || "development"
  require "./app"
end

namespace :db do
  desc "Seed database"
  task :seed, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    puts "----"
    puts "SEEDING DATABASE for environment [#{env}]"
    puts "----"

    # Roles
    puts "  Creating roles"
    Applyance::Server.db[:roles].insert(:name => "chief")
    Applyance::Server.db[:roles].insert(:name => "citizen")
    Applyance::Server.db[:roles].insert(:name => "reviewer")

    # Domains
    puts "  Creating Domains"
    Applyance::Domain.create(:name => "Employers")
    Applyance::Domain.create(:name => "Schools")

    # Features
    puts "  Creating Features"
    feature_applicantList_id = Applyance::Server.db[:entity_customer_features].insert(:name => "applicantList")
    feature_applicantManagement_id = Applyance::Server.db[:entity_customer_features].insert(:name => "applicantManagement")
    feature_applicantView_id = Applyance::Server.db[:entity_customer_features].insert(:name => "applicantView")
    feature_spots_id = Applyance::Server.db[:entity_customer_features].insert(:name => "spots")
    feature_locations_id = Applyance::Server.db[:entity_customer_features].insert(:name => "locations")
    feature_questions_id = Applyance::Server.db[:entity_customer_features].insert(:name => "questions")
    feature_team_id = Applyance::Server.db[:entity_customer_features].insert(:name => "team")
    feature_labels_id = Applyance::Server.db[:entity_customer_features].insert(:name => "labels")

    # Plans
    puts "  Creating plans."
    free_plan_id = Applyance::Server.db[:entity_customer_plans].insert(:name => "Free", :stripe_id => "free", :created_at => DateTime.now)
    premium_plan_id = Applyance::Server.db[:entity_customer_plans].insert(:name => "Premium", :stripe_id => "premium", :created_at => DateTime.now)

    # Assign features to plans
    puts "  Assigning features to FREE plan."
    Applyance::DB::Seed::Util.add_feature_to_plan(free_plan_id, feature_spots_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(free_plan_id, feature_locations_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(free_plan_id, feature_questions_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(free_plan_id, feature_applicantView_id)

    puts "  Assigning features to PAID plan."
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_spots_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_applicantList_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_applicantManagement_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_applicantView_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_locations_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_questions_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_team_id)
    Applyance::DB::Seed::Util.add_feature_to_plan(premium_plan_id, feature_labels_id)

  end

  desc "Empty the database (truncate all tables)"
  task :empty, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)
    Applyance::Server.db.tables.each do |table|
      unless table.to_s == "schema_info"
        Applyance::Server.db.run("TRUNCATE TABLE #{table} CASCADE")
      end
    end
  end

  desc "Reseed the database"
  task :reseed, [:env] => [:empty, :seed]
end
