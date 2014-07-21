module Applyance
  class Definition < Sequel::Model

    include Applyance::Lib::Strings

    plugin :serialization, :json, :helper

    many_to_one :domain, :class => :'Applyance::Domain'
    many_to_one :unit, :class => :'Applyance::Unit'
    one_to_many :answers, :class => :'Applyance::Answer'
    one_to_many :blueprints, :class => :'Applyance::Blueprint'

    def before_validation
      super
      self.name = to_slug(self.label)
    end

    def validate
      super
      validates_presence [:label, :type]
    end
  end
end
