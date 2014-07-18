module Applyance
  class Segment < Sequel::Model
    many_to_one :reviewer, :class => :'Applyance::Reviewer'
  end
end
