Sequel.migration do
  change do

    # Create roles
    create_table(:roles) do
      primary_key :id
      String :name, :null => false, :unique => true
    end
    self[:roles].insert(:name => "applicant")
    self[:roles].insert(:name => "reviewer")

    # Create accounts
    create_table(:accounts) do
      primary_key :id

      String :name, :null => false
      String :email, :null => false, :unique => true
      String :password_hash, :null => false
      String :api_key, :null => false, :unique => true
      TrueClass :is_verified, :default => false

      String :verify_digest, :unique => true
      String :reset_digest, :unique => true

      DateTime :created_at
      DateTime :updated_at
    end

    # Create account role relationship
    create_table(:accounts_roles) do
      foreign_key :account_id, :accounts
      foreign_key :role_id, :roles
    end

  end
end
