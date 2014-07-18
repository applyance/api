module Applyance
  class Attachment < Sequel::Model
    many_to_many :templates, :class => :'Applyance::Template'
    many_to_many :messages, :class => :'Applyance::Message'
    many_to_many :answers, :class => :'Applyance::Answer'
  end
end
