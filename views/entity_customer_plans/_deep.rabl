attributes :id, :name, :stripe_id, :created_at, :updated_at

child :features => :features do
  extends 'entity_customer_features/_shallow'
end
