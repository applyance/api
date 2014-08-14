attributes :id, :stripe_id, :last4, :exp_month, :exp_year, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end
