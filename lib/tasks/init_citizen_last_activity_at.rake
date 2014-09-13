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
  desc "Initialize Citizen Activity"
  task :init_citizen_activity, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    Applyance::Server.db[:citizens].each do |citizen|
      Applyance::Server.db[:citizens]
        .where(:id => citizen[:id])
        .where(:last_activity_at => nil)
        .update(:last_activity_at => DateTime.now)
    end
  end
end
