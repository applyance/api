Sequel.migration do
  change do

    alter_table(:admins) do
      add_column :access_level, String, :null => false, :default => "limited"
    end

    alter_table(:admin_invites) do
      add_column :access_level, String, :null => false, :default => "limited"
    end

    alter_table(:reviewers) do
      set_column_default :access_level, "limited"
      drop_column :is_entity_admin
    end

    alter_table(:reviewer_invites) do
      set_column_default :access_level, "limited"
    end
  end
end
