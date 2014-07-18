module Applyance
  class Role < Sequel::Model
    many_to_many :accounts, :class => :'Applyance::Account'
  end
end
