module Applyance
  class Entity < Sequel::Model

    include Applyance::Lib::Attachments

    many_to_one :domain, :class => :'Applyance::Domain'
    one_to_many :admins, :class => :'Applyance::Admin'
    one_to_many :admin_invites, :class => :'Applyance::AdminInvite'
    one_to_many :units, :class => :'Applyance::Unit'
    many_to_many :blueprints, :class => :'Applyance::Blueprint'
    many_to_one :logo, :class => :'Applyance::Attachment'

    def validate
      super
      validates_presence :name
    end
  end
end
