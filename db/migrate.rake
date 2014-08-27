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
  desc "Load Schema"
  task :load_schema, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    require 'sequel/extensions/migration'
    Sequel::Migrator.apply(Applyance::Server.db, "db/schema")
  end

  desc "Run database migrations"
  task :migrate, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    require 'sequel/extensions/migration'
    Sequel::Migrator.apply(Applyance::Server.db, "db/migrations")
  end

  desc "Rollback the database"
  task :rollback, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    require 'sequel/extensions/migration'
    version = (row = Applyance::Server.db[:schema_info].first) ? row[:version] : nil
    Sequel::Migrator.apply(Applyance::Server.db, "db/migrations", version - 1)
  end

  desc "Nuke the database (drop all tables)"
  task :nuke, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)
    Applyance::Server.db.tables.each do |table|
      Applyance::Server.db.run("DROP TABLE #{table} CASCADE")
    end
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

  desc "Reset the database"
  task :reset, [:env] => [:nuke, :migrate]
end
