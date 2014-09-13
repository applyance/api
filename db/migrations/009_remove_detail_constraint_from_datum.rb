Sequel.migration do
  up do
    alter_table(:datums) do
      set_column_allow_null :detail
    end
    Applyance::Server.db[:citizens].each do |citizen|
      Applyance::Server.db[:citizens]
        .where(:id => citizen[:id])
        .where(:last_activity_at => nil)
        .update(:last_activity_at => DateTime.now)
    end
  end
  down do
    alter_table(:datums) do
      set_column_not_null :detail
    end
  end
end
