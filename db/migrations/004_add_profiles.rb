Sequel.migration do
  up do

    # Create profiles
    create_table(:profiles) do
      primary_key :id

      foreign_key :account_id, :accounts, :on_delete => :cascade, :unique => true
      foreign_key :location_id, :locations, :on_delete => :set_null
      String :phone_number

      DateTime :created_at
      DateTime :updated_at
    end

    # Altering citizens to have relationship with entity
    alter_table(:citizens) do
      add_foreign_key :entity_id, :entities, :on_delete => :cascade
      add_index [:entity_id, :account_id], :unique => true
      drop_constraint(:applicants_account_id_key)
    end

    Applyance::Server.db[:citizens].each do |citizen|
      Applyance::Server.db[:applications].where(:citizen_id => citizen[:id]).each do |application|
        Applyance::Server.db[:applications_entities].where(:application_id => application[:id]).each do |application_entity|
          Applyance::Server.db[:citizens].where(:id => citizen[:id]).update(:entity_id => application_entity[:entity_id])
        end
      end
    end

    # Altering datums to sync with profiles
    alter_table(:datums) do
      add_foreign_key :profile_id, :profiles, :on_delete => :cascade
    end

    Applyance::Server.db[:citizens].each do |citizen|
      profile_id = Applyance::Server.db[:profiles].insert(
        :account_id => citizen[:account_id],
        :location_id => citizen[:location_id],
        :phone_number => citizen[:phone_number])
      Applyance::Server.db[:datums].where(:citizen_id => citizen[:id]).update(:profile_id => profile_id)
    end

    # Altering citizens to have relationship with entity
    alter_table(:citizens) do
      drop_foreign_key :location_id
      drop_column :phone_number
    end

    # Drop citizen id from datums
    alter_table(:datums) do
      drop_foreign_key :citizen_id
    end

    create_table(:applications_citizens) do
      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :citizen_id, :citizens, :on_delete => :cascade
      index [:application_id, :citizen_id], :unique => true
    end

    Applyance::Server.db[:applications].each do |application|
      Applyance::Server.db[:applications_citizens].insert(
        :application_id => application[:id],
        :citizen_id => application[:citizen_id]
      )
    end

    alter_table(:applications) do
      drop_foreign_key :citizen_id
    end

  end
  down do

    alter_table(:applications) do
      add_foreign_key :citizen_id, :citizens, :on_delete => :set_null
    end

    Applyance::Server.db[:applications_citizens].each do |application_citizen|
      Applyance::Server.db[:applications].where(:id => application_citizen[:application_id]).update(
        :citizen_id => application_citizen[:citizen_id]
      )
    end

    drop_table(:applications_citizens)

    alter_table(:datums) do
      add_foreign_key :citizen_id, :citizens, :on_delete => :cascade
    end

    # Altering citizens to have relationship with entity
    alter_table(:citizens) do
      add_foreign_key :location_id, :locations, :on_delete => :set_null
      add_column :phone_number, String
      add_unique_constraint [:account_id]
    end

    Applyance::Server.db[:profiles].each do |profile|
      Applyance::Server.db[:citizens].where(:account_id => profile[:account_id]).update(
        :location_id => profile[:location_id],
        :phone_number => profile[:phone_number]
      )
      citizen = Applyance::Server.db[:citizens].first(:account_id => profile[:account_id])
      Applyance::Server.db[:datums].where(:profile_id => profile[:id]).update(:citizen_id => citizen[:id])
    end

    alter_table(:datums) do
      drop_foreign_key :profile_id
    end

    alter_table(:citizens) do
      drop_foreign_key :entity_id
    end

    drop_table(:profiles)

  end
end
