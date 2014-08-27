module Applyance
  class Citizen < Sequel::Model

    many_to_one :account, :class => :'Applyance::Account'
    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :stage, :class => :'Applyance::Stage'

    one_to_many :activities, :class => :'Applyance::CitizenActivity'
    one_to_many :threads, :class => :'Applyance::Thread'
    one_to_many :ratings, :class => :'Applyance::Rating'

    many_to_many :labels, :class => :'Applyance::Label'
    many_to_many :applications, :class => :'Applyance::Application'

    dataset_module do
      def by_last_active
        reverse_order(:last_activity_at)
      end
    end

  end
end
