module Applyance
  module Migration013
    class Util
      extend Applyance::Lib::Tokens
    end
  end
end

Sequel.migration do
  up do

    puts "Modify the definition table."

    alter_table(:definitions) do
      add_column :placeholder, String
      add_column :is_default, TrueClass, :default => false
      add_column :default_is_required, TrueClass, :default => false
      add_column :default_position, Integer, :default => 10
    end

    puts "Modify the profiles table."

    alter_table(:accounts) do
      add_column :phone_number, String
      add_column :is_phone_verified, TrueClass, :default => false
      add_column :phone_verify_digest, String
    end

    Applyance::Server.db[:accounts].each do |account|
      Applyance::Server.db[:accounts]
        .where(:id => account[:id])
        .update(:phone_verify_digest => Applyance::Migration013::Util.friendly_pin)
    end

    Applyance::Server.db[:profiles].each do |profile|
      Applyance::Server.db[:accounts]
        .where(:id => profile[:account_id])
        .update(:phone_number => profile[:phone_number])
    end

    alter_table(:profiles) do
      drop_foreign_key :location_id
      drop_column :phone_number
    end

    puts "Change core values to default values."

    Applyance::Server.db[:definitions].each do |definition|
      Applyance::Server.db[:definitions]
        .where(:id => definition[:id])
        .update(
          :is_default => definition[:is_core],
          :is_core => false)
    end

  end
  down do

    Applyance::Server.db[:definitions].each do |definition|
      Applyance::Server.db[:definitions]
        .where(:id => definition[:id])
        .update(:is_core => definition[:is_default])
    end

    alter_table(:definitions) do
      drop_column :placeholder
      drop_column :is_default
      drop_column :default_is_required
      drop_column :default_position
    end

    alter_table(:profiles) do
      add_foreign_key :location_id, :locations, :on_delete => :set_null
      add_column :phone_number, String
    end

    Applyance::Server.db[:accounts].each do |account|
      Applyance::Server.db[:profiles]
        .where(:account_id => account[:id])
        .update(:phone_number => account[:phone_number])
    end

    alter_table(:accounts) do
      drop_column :phone_number
      drop_column :is_phone_verified
      drop_column :phone_verify_digest
    end

  end
end
