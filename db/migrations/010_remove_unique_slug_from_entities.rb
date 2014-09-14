Sequel.migration do
  up do
    alter_table(:entities) do
      drop_constraint(:entities_slug_key)
      add_index [:slug, :parent_id], :name => :entities_slug_parent_key, :unique => true
    end
  end
  down do
    alter_table(:entities) do
      drop_constraint(:entities_slug_parent_key)
      add_index [:slug], :unique => true, :name => :entities_slug_key
    end
  end
end
