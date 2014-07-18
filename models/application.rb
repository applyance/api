module Applyance
  class Application < Sequel::Model
    many_to_one :submitter, :class => :'Applyance::Account'
    many_to_one :submitted_from, :class => :'Applyance::Coordinate'
    many_to_one :stage, :class => :'Applyance::Stage'
    many_to_many :spots, :class => :'Applyance::Spot'
    many_to_many :reviewers, :class => :'Applyance::Reviewer'
    many_to_many :labels, :class => :'Applyance::Label'
    one_to_many :activities, :class => :'Applyance::ApplicationActivity'
    one_to_many :threads, :class => :'Applyance::Thread'
    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :ratings, :class => :'Applyance::Rating'
    one_to_many :fields, :class => :'Applyance::Field'
  end
end
