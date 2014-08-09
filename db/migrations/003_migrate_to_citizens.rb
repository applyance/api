Sequel.migration do
  up do
    rename_table(:applicants, :citizens)
    rename_column :applications, :applicant_id, :citizen_id
    rename_column :datums, :applicant_id, :citizen_id

    alter_table(:ratings) do
      add_foreign_key :citizen_id, :citizens, :on_delete => :cascade
      add_index [:citizen_id, :account_id], :unique => true

      drop_index [:application_id, :account_id]
      drop_foreign_key :application_id
    end

    alter_table(:applications) do
      drop_foreign_key :stage_id
    end

    alter_table(:citizens) do
      add_foreign_key :stage_id, :stages, :on_delete => :set_null
    end

    alter_table(:threads) do
      add_foreign_key :citizen_id, :citizens, :on_delete => :cascade
      drop_foreign_key :application_id
    end

    create_table(:citizens_labels) do
      foreign_key :citizen_id, :citizens, :on_delete => :cascade
      foreign_key :label_id, :labels, :on_delete => :cascade
    end

    drop_table(:applications_labels)

    # Update the applicant role to citizen
    Applyance::Server.db[:roles].where(:name => "applicant").update(:name => "citizen")
  end
  down do
    Applyance::Server.db[:roles].where(:name => "citizen").update(:name => "applicant")

    create_table(:applications_labels) do
      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :label_id, :labels, :on_delete => :cascade
    end

    drop_table(:citizens_labels)

    alter_table(:threads) do
      add_foreign_key :application_id, :applications, :on_delete => :cascade
      drop_foreign_key :citizen_id
    end

    alter_table(:applications) do
      add_foreign_key :stage_id, :stages, :on_delete => :set_null
    end

    alter_table(:citizens) do
      drop_foreign_key :stage_id
    end

    alter_table(:ratings) do
      add_foreign_key :application_id, :applications, :on_delete => :cascade
      add_index [:application_id, :account_id], :unique => true

      drop_index [:citizen_id, :account_id]
      drop_foreign_key :citizen_id
    end

    rename_table(:citizens, :applicants)
    rename_column :datums, :citizen_id, :applicant_id
    rename_column :applications, :citizen_id, :applicant_id

  end
end
