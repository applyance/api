module Applyance
  class ApplicationActivity < Sequel::Model
    many_to_one :application, :class => :'Applyance::Application'

    def after_create
      super

      # Update the application's last activity time
      self.application.update(:last_activity_at => self.activity_at)
    end

    # Create a new submission activity
    def self.make_for_submission(application)
      self.create(
        :application_id => application.id,
        :detail => "New application submission.",
        :object_type => application.class.name,
        :object_id => application.id,
        :activity_at => DateTime.now)
    end
  end
end
