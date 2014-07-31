module Applyance
  class Applicant < Sequel::Model

    many_to_one :account, :class => :'Applyance::Account'
    many_to_one :location, :class => :'Applyance::Location'
    
    one_to_many :applications, :class => :'Applyance::Application'
    one_to_many :datums, :class => :'Applyance::Datum'

  end
end
