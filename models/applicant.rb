module Applyance
  class Applicant < Sequel::Model

    many_to_one :account, :class => :'Applyance::Account'
    one_to_many :applications, :class => :'Applyance::Application'
    one_to_many :datums, :class => :'Applyance::Datum'

  end
end
