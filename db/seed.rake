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
    Applyance::Server.db[:roles].insert(:name => "admin")
    Applyance::Server.db[:roles].insert(:name => "reviewer")

    Applyance::Server.db[:domains].insert(:name => "retail")
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
