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
    Applyance::Domain.create(:name => "Employers")
    Applyance::Domain.create(:name => "Schools")
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
