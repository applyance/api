module Applyance
  class Datum < Sequel::Model

    include Applyance::Lib::Attachments

    many_to_one :account, :class => :'Applyance::Account'
    many_to_one :definition, :class => :'Applyance::Definition'
    one_to_many :fields, :class => :'Applyance::Field'
    many_to_many :attachments, :class => :'Applyance::Attachment', :join_table => :attachments_datums

    def validate
      super
      validates_presence :detail
    end
  end
  Datum.set_dataset :datums
end
