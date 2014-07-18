module Applyance
  class Answer < Sequel::Model
    many_to_one :account, :class => :'Applyance::Account'
    many_to_one :definition, :class => :'Applyance::Definition'
    many_to_many :attachments, :class => :'Applyance::Attachment'
    one_to_many :fields, :class => :'Applyance::Field'
  end
end
