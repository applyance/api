module Applyance
  class Rating < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
    many_to_one :reviewer, :class => :'Applyance::Reviewer'
    many_to_one :spot, :class => :'Applyance::Spot'
  end
end
