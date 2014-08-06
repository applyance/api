Sequel.migration do
  up do
    add_column :spots, :slug, String
    add_column :spots, :'_slug', String
  end
  down do
    drop_column :spots, :slug
    drop_column :spots, :'_slug'
  end
end
