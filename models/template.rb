module Applyance
  class Template < Sequel::Model

    include Applyance::Lib::Attachments

    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_many :attachments, :class => :'Applyance::Attachment'
  end
end
