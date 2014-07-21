module Applyance
  class Attachment < Sequel::Model
    many_to_many :templates, :class => :'Applyance::Template'
    many_to_many :messages, :class => :'Applyance::Message'
    many_to_many :datums, :class => :'Applyance::Datum'

    def validate
      super
      validates_presence [:token, :name, :url, :content_type]
      validates_unique :token
    end
  end
end
