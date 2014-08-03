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

    Applyance::Server.db[:roles].insert(:name => "chief")
    Applyance::Server.db[:roles].insert(:name => "applicant")
    Applyance::Server.db[:roles].insert(:name => "reviewer")

    # Domains
    Applyance::Domain.create(:name => "retail")
  end

  # Definitions
  desc "Seed definitions"
  task :seed_definitions, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    Applyance::Definition.create(
      :name => 'Social Security Number',
      :label => 'Social Security Number',
      :type => 'text',
      :is_sensitive => true
    )
    Applyance::Definition.create(
      :name => 'Phone Number',
      :label => 'Phone Number',
      :type => 'text'
    )
    Applyance::Definition.create(
      :name => 'Date of Birth',
      :label => 'Date of Birth',
      :type => 'text'
    )
    Applyance::Definition.create(
      :name => 'Current Address',
      :label => 'Current Address',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'Previous Address',
      :label => 'Previous Address',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'References',
      :label => 'References',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'Education History',
      :label => 'Education History',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'Employment History',
      :label => 'Employment History',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'Criminal Activity',
      :label => 'Criminal Activity',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'Hours of Availability',
      :label => 'Hours of Availability',
      :type => 'special'
    )
    Applyance::Definition.create(
      :name => 'Able to work in the US',
      :label => 'Are you legally allowed to work in the United States?',
      :description => 'This helps us determine your eligibility.',
      :type => 'choice',
      :helper => {
        :choices => ["Yes", "No"]
      }
    )
    Applyance::Definition.create(
      :name => 'How would they be an asset?',
      :label => 'Please explain how you would be an asset to {{ entity.name }}.',
      :type => 'textarea',
      :is_contextual => true
    )
  end

  desc "Empty the database (truncate all tables)"
  task :empty, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)
    Applyance::Server.db.tables.each do |table|
      Applyance::Server.db.run("TRUNCATE TABLE #{table} CASCADE") if table != "schema_info"
    end
  end

  desc "Reseed the database"
  task :reseed, [:env] => [:empty, :seed]
end
