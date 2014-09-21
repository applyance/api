module Applyance
  class EntityCustomerFeature < Sequel::Model
    many_to_many :plans, :class => :'Applyance::EntityCustomerPlan',
      :left_key => :entity_customer_feature_id, :right_key => :entity_customer_plan_id
  end
end
