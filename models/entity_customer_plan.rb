module Applyance
  class EntityCustomerPlan < Sequel::Model
    many_to_many :features, :class => :'Applyance::EntityCustomerFeature',
      :left_key => :entity_customer_plan_id, :right_key => :entity_customer_feature_id
    one_to_many :customers, :class => :'Applyance::EntityCustomer'
  end
end
