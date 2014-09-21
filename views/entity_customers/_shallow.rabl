attributes :id, :entity_id, :stripe_id, :stripe_subscription_id, :subscription_status, :active_until, :last4, :exp_month, :exp_year, :created_at, :updated_at

child :plan => :plan do
  extends 'entity_customer_plans/_deep'
end
