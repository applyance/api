module Applyance
  class Stage < Sequel::Model
    many_to_one :pipeline, :class => :'Applyance::Pipeline'
    one_to_many :applications, :class => :'Applyance::Application'

    def before_validation
      super

      # Increment all positions greater than or equal to this position
      Stage
        .where(:pipeline_id => self.pipeline_id)
        .where('position >= ?', self.position)
        .update(:position => Sequel.+(:position, 1))
    end
  end
end
