Sequel.migration do
  up do
    rename_table(:application_activities, :citizen_activities)
    alter_table(:citizen_activities) do
      add_foreign_key :citizen_id, :citizens, :on_delete => :cascade
    end

    alter_table(:citizens) do
      add_column :last_activity_at, DateTime
    end

    # Logic here to update references
    Applyance::Server.db[:citizen_activities].each do |citizen_activity|

      citizen_id = Applyance::Server.db[:applications_citizens]
        .where(:application_id => citizen_activity[:application_id])
        .first[:citizen_id]

      Applyance::Server.db[:citizen_activities]
        .where(:id => citizen_activity[:id])
        .update(:citizen_id => citizen_id)

    end

    Applyance::Server.db[:citizens].each do |citizen|
      citizen_activity = Applyance::Server.db[:citizen_activities]
        .where(:citizen_id => citizen[:id])
        .all.last
      if citizen_activity
        Applyance::Server.db[:citizens]
          .where(:id => citizen[:id])
          .update(:last_activity_at => citizen_activity[:activity_at])
      end
    end

    alter_table(:citizen_activities) do
      drop_foreign_key :application_id
    end

    alter_table(:applications) do
      drop_column :last_activity_at
    end

  end

  down do
    alter_table(:citizen_activities) do
      add_foreign_key :application_id, :applications, :on_delete => :cascade
    end

    alter_table(:applications) do
      add_column :last_activity_at, DateTime
    end

    # Logic here to update references
    Applyance::Server.db[:citizen_activities].each do |citizen_activity|

      application_id = Applyance::Server.db[:applications_citizens]
        .where(:citizen_id => citizen_activity[:citizen_id])
        .first[:application_id]

      Applyance::Server.db[:citizen_activities]
        .where(:id => citizen_activity[:id])
        .update(:application_id => application_id)

    end

    Applyance::Server.db[:applications].each do |application|
      citizen_activity = Applyance::Server.db[:citizen_activities]
        .where(:application_id => application[:id])
        .all.last
      if citizen_activity
        Applyance::Server.db[:applications]
          .where(:id => application[:id])
          .update(:last_activity_at => citizen_activity[:activity_at])
      end
    end

    alter_table(:citizen_activities) do
      drop_foreign_key :citizen_id
    end
    rename_table(:citizen_activities, :application_activities)

    alter_table(:citizens) do
      drop_column :last_activity_at
    end

  end
end
