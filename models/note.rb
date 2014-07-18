module Applyance
  class Note < Sequel::Model
    many_to_one :reviewer, :class => :'Applyance::Reviewer'
    many_to_one :application, :class => :'Applyance::Application'
  end
end
