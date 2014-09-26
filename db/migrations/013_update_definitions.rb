Sequel.migration do
  up do

    puts "Modify the definition table."

    alter_table(:definitions) do
      add_column :placeholder, String
      add_column :is_default, TrueClass, :default => false
      add_column :default_is_required, TrueClass, :default => false
      add_column :default_position, Integer, :default => 10
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

  end
end
