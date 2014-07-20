module Applyance
  class Definition < Sequel::Model

    include Applyance::Lib::Strings

    plugin :serialization, :json, :helper

    one_to_many :answers, :class => :'Applyance::Answer'
    one_to_many :blueprints, :class => :'Applyance::Blueprint'
    one_through_one :domain, :class => :'Applyance::Domain'
    one_through_one :unit, :class => :'Applyance::Unit'

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
