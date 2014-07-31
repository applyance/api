module Applyance
  class Rating < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
    many_to_one :reviewer, :class => :'Applyance::Reviewer'
  end
end
