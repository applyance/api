attributes :id, :name, :stripe_id

child :features => :features do
  extends 'entity_customer_features/_shallow'
end
