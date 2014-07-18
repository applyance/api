module Applyance
  class Reviewer < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
    many_to_one :account, :class => :'Applyance::Account'
    one_to_many :segments, :class => :'Applyance::Segment'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :ratings, :class => :'Applyance::Rating'
  end
end
