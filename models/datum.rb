module Applyance
  class Datum < Sequel::Model(:datums)

    include Applyance::Lib::Attachments

    plugin :serialization, :json, :detail

    many_to_one :profile, :class => :'Applyance::Profile'
    many_to_one :definition, :class => :'Applyance::Definition'
    one_to_many :fields, :class => :'Applyance::Field'
    many_to_many :attachments, :class => :'Applyance::Attachment', :join_table => :attachments_datums

    def validate
      super
      validates_presence :detail
    end
  end
end
