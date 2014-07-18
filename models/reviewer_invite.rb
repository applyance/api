module Applyance
  class ReviewerInvite < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
  end
end
