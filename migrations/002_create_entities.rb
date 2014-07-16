Sequel.migration do
  change do

    # Create entities
    create_table(:entities) do
      primary_key :id

      String :name, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create members for the entities
    create_table(:entity_members) do
      primary_key :id

      foreign_key :entity_id, :entities
      foreign_key :member_id, :accounts

      String :role, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create member invitations for the entities
    create_table(:entity_member_invitations) do
      primary_key :id
      foreign_key :entity_id, :entities

      String :email, :null => false
      String :digest, :null => false, :unique => true
      String :status, :default => "open"

      DateTime :created_at
      DateTime :updated_at
    end

    # Create member segments for the entities
    create_table(:entity_member_segments) do
      primary_key :id

      foreign_key :entity_id, :entities
      foreign_key :member_id, :entity_members

      String :name, :null => false
      String :dsl, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
