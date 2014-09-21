attribute :id, :stripe_invoice_id, :stripe_charge_id, :starting_balance, :ending_balance, :subtotal, :discount, :total, :amount_due, :is_attempted, :is_paid, :is_closed, :is_forgiven, :period_start, :period_end, :created_at, :updated_at

child :customer => :customer do
  extends 'entity_customers/_shallow'
end
