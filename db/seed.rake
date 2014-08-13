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
    Applyance::Server.db[:roles].insert(:name => "citizen")
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
      :type => 'text'
    )
    Applyance::Definition.create(
      :name => 'Date of Birth',
      :label => 'Date of Birth',
      :type => 'text'
    )
    Applyance::Definition.create(
      :name => 'Online Presence',
      :label => 'Do you have a personal website, blog, or facebook?',
      :type => 'textarea'
    )
    Applyance::Definition.create(
      :name => 'Hours of Availability',
      :label => 'What are your hours of availability?',
      :type => 'textarea'
    )
    Applyance::Definition.create(
      :name => 'Previous Work at this Institution',
      :label => 'Have you ever worked for our institution before? If so, when? Who was your supervisor? Why did you leave and why do you want to come back?',
      :type => 'textarea',
      :is_contextual => true
    )
    Applyance::Definition.create(
      :name => 'Knowledge of Employees',
      :label => 'Do you know any of our current or former employees? If so, who?',
      :type => 'textarea',
      :is_contextual => true
    )
    Applyance::Definition.create(
      :name => 'Previous Three Jobs',
      :label => 'What are the last three previous jobs you have had?',
      :description => 'Include business name, position title, location, phone number, start and end date, job duties, and name of supervisor.',
      :type => 'textarea'
    )
    Applyance::Definition.create(
      :name => 'Why should we hire you?',
      :label => 'Why should we hire you?',
      :type => 'textarea',
      :is_contextual => true
    )
    Applyance::Definition.create(
      :name => 'Education History',
      :label => 'What is your education history?',
      :description => 'Include instituation name, years of attendance, and degree.',
      :type => 'textarea'
    )
    Applyance::Definition.create(
      :name => 'Work Eligibility in the U.S.',
      :label => 'Are you eligible to work in the United States?',
      :type => 'choice',
      :helper => {
        :choices => ["Yes", "No"]
      }
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
