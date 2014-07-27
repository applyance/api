Sequel.migration do
  change do

    # Create addresses
    create_table(:addresses) do
      primary_key :id

      String :address_1
      String :address_2
      String :city
      String :state
      String :postal_code
      String :country

      DateTime :created_at
      DateTime :updated_at
    end

    # Create locations
    create_table(:locations) do
      primary_key :id

      foreign_key :coordinate_id, :coordinates, :on_delete => :set_null
      foreign_key :address_id, :addresses, :on_delete => :set_null

      DateTime :created_at
      DateTime :updated_at
    end

    # Create applicants
    create_table(:applicants) do
      primary_key :id

      foreign_key :account_id, :accounts, :on_delete => :cascade, :unique => true
      foreign_key :location_id, :locations, :on_delete => :set_null

      DateTime :created_at
      DateTime :updated_at
    end

    alter_table(:applications) do
      drop_column :submitter_id
      drop_column :submitted_from_id
      add_foreign_key :applicant_id, :applicants, :on_delete => :set_null
    end

    alter_table(:datums) do
      drop_column :account_id
      add_foreign_key :applicant_id, :applicants, :on_delete => :cascade
    end

  end
end
