Sequel.migration do
  up do
    alter_table(:datums) do
      set_column_allow_null :detail
    end
  end
  down do
    alter_table(:datums) do
      set_column_not_null :detail
    end
  end
end
