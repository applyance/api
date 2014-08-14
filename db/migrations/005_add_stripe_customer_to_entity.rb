Sequel.migration do
  up do
    # Add stripe customer to entity
    create_table(:entity_customers) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade, :unique => true
      String :stripe_id
      String :last4
      String :exp_month
      String :exp_year

      DateTime :created_at
      DateTime :updated_at
    end
  end
  down do
    drop_table(:entity_customers)
  end
end
