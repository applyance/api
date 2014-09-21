attributes :id, :stripe_id, :stripe_subscription_id, :subscription_status, :active_until, :last4, :exp_month, :exp_year, :created_at, :updated_at

child :entity => :entity do
  extends 'entities/_shallow'
end

child :plan => :plan do
  extends 'entity_customer_plans/_deep'
end

child :invoices => :invoices do
  extends 'entity_customer_invoices/_shallow'
end
