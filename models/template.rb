module Applyance
  class Template < Sequel::Model
    many_to_one :unit, :class => :'Applyance::Unit'
    many_to_many :attachments, :class => :'Applyance::Attachment'
  end
end
