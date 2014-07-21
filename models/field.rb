module Applyance
  class Field < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'
    many_to_one :datum, :class => :'Applyance::Datum'
  end
end
