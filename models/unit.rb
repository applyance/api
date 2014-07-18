module Applyance
  class Unit < Sequel::Model
    many_to_one :entity, :class => :'Applyance::Entity'
    one_to_many :reviewers, :class => :'Applyance::Reviewer'
    one_to_many :reviewer_invites, :class => :'Applyance::ReviewerInvite'
    one_to_many :spots, :class => :'Applyance::Spot'
    one_to_many :templates, :class => :'Applyance::Template'
    one_to_many :pipelines, :class => :'Applyance::Pipeline'
    one_to_many :labels, :class => :'Applyance::Label'
    one_to_many :definitions, :class => :'Applyance::Definition'
  end
end
