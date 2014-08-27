module Applyance
  class CitizenActivity < Sequel::Model
    many_to_one :citizen, :class => :'Applyance::Citizen'

    def after_create
      super

      # Update the application's last activity time
      self.citizen.update(:last_activity_at => self.activity_at)
    end

    # Create a new submission activity
    def self.make_for_application_submission(application)
      application.citizens.each do |citizen|
        self.create(
          :citizen_id => citizen.id,
          :detail => "New application submission.",
          :object_type => application.class.name,
          :object_id => application.id,
          :activity_at => DateTime.now)
      end
    end
  end
end
