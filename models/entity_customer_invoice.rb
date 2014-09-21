module Applyance
  class EntityCustomerInvoice < Sequel::Model

    many_to_one :customer, :class => :'Applyance::EntityCustomer'

    def update_from_stripe(stripe_invoice)
      self.update(
        :stripe_invoice_id => stripe_invoice.id,
        :stripe_charge_id => stripe_invoice.charge,
        :starting_balance => stripe_invoice.starting_balance,
        :ending_balance => stripe_invoice.ending_balance,
        :subtotal => stripe_invoice.subtotal,
        :total => stripe_invoice.total,
        :discount => stripe_invoice.subtotal - stripe_invoice.total,
        :amount_due => stripe_invoice.amount_due,
        :is_paid => stripe_invoice.paid,
        :is_attempted => stripe_invoice.attempted,
        :is_closed => stripe_invoice.closed,
        :is_forgiven => stripe_invoice.forgiven,
        :period_start => Time.at(stripe_invoice.period_start).utc.to_datetime,
        :period_end => Time.at(stripe_invoice.period_start).utc.to_datetime
      )
    end

  end
end
