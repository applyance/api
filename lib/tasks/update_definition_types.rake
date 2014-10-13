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

  desc "Assign blueprints"
  task :clean_blueprints, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    puts "Repositioning blueprints."

    Applyance::Blueprint.all.each do |blueprint|
      blueprint.update(
        :is_required => blueprint.definition.default_is_required,
        :position => blueprint.definition.default_position
      )
    end

    puts "Assigning blueprint cores."

    core_definitions = Applyance::Definition.where(:is_core => true)
    entities = Applyance::Entity.where(:parent_id => nil)
    entities.each do |entity|
      core_definitions.each do |definition|
        blueprints_exist = entity.blueprints_dataset.where(:definition_id => definition.id).count
        unless blueprints_exist > 0
          blueprint = Applyance::Blueprint.create(
            :definition_id => definition.id,
            :position => definition.default_position,
            :is_required => definition.default_is_required
          )
          entity.add_blueprint(blueprint)
          puts "Added blueprint [#{definition.label}] for entity [#{entity.id} - #{entity.name}]"
        else
          puts "Skipped blueprint [#{definition.label}] for entity [#{entity.id} - #{entity.name}]"
        end
      end
    end
  end

  desc "Clean up datums"
  task :clean_datums, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    puts "Cleaning datums."

    datums = Applyance::Datum.all
    datums.each do |datum|
      datum.definition = Applyance::Definition.first(:type => "longtext")
      datum.detail = { :entries => [{ :value => datum.detail['value'] }] }
      datum.save
      puts "Saved datum."
    end
  end

end
