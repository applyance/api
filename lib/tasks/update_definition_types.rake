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
  desc "Update definition types"
  task :update_definition_types, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    puts "Updating definition types."

    Applyance::Server.db[:definitions].each do |definition|
      new_type = nil
      if definition[:type] == "text"
        new_type = "shorttext"
      elsif definition[:type] == "textarea"
        new_type = "longtext"
      elsif definition[:type] == "choice"
        new_type = "dropdown"
      end
      if new_type
        puts "  ----"
        puts "  Switching type from [#{definition[:type]}] to [#{new_type}] for [#{definition[:name]}]."
        Applyance::Server.db[:definitions]
          .where(:id => definition[:id])
          .update(:type => new_type)
        puts "  Success"
      end
    end
  end
end
