module Applyance
  class AdminInvite < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
  end
end
