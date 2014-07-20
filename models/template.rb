module Applyance
  class Template < Sequel::Model

    include Applyance::Lib::Attachments
    
    many_to_one :unit, :class => :'Applyance::Unit'
    many_to_many :attachments, :class => :'Applyance::Attachment'
  end
end
