Sequel.migration do
  up do
    add_column :definitions, :is_core, TrueClass, :default => false
  end
  down do
    drop_column :definitions, :is_core
  end
end
