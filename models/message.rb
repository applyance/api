module Applyance
  class Message < Sequel::Model

    include Applyance::Lib::Attachments
    
    many_to_one :thread, :class => :'Applyance::Thread'
    many_to_one :sender, :class => :'Applyance::Account'
    many_to_many :attachments, :class => :'Applyance::Attachment'
  end
end
