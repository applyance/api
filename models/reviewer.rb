module Applyance
  class Reviewer < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
    many_to_one :account, :class => :'Applyance::Account'
    one_to_many :segments, :class => :'Applyance::Segment'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :ratings, :class => :'Applyance::Rating'

    def self.make_from_admin(unit, admin)
      reviewer = self.create(
        :unit_id => unit.id,
        :account_id => admin.account_id,
        :access_level => "full",
        :is_entity_admin => true)
      reviewer
    end
  end
end
