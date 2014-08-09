module Applyance
  class Citizen < Sequel::Model

    many_to_one :account, :class => :'Applyance::Account'
    many_to_one :location, :class => :'Applyance::Location'
    many_to_one :stage, :class => :'Applyance::Stage'

    one_to_many :applications, :class => :'Applyance::Application'
    one_to_many :datums, :class => :'Applyance::Datum'
    one_to_many :threads, :class => :'Applyance::Thread'
    one_to_many :ratings, :class => :'Applyance::Rating'

    many_to_many :labels, :class => :'Applyance::Label'

    # Welcome the new reviewer by way of email
    def send_welcome_email(temp_password)
      return if Applyance::Server.test?
      m = Mandrill::API.new(Applyance::Server.settings.mandrill_api_key)
      message = {
        :subject => "Welcome to Applyance",
        :from_name => "The Team at Applyance",
        :text => "Hello #{self.account.name},\n\nWelcome to Applyance. We're on an ambitious mission to replace grueling applications with a delightful experience. We hope you enjoy applying with us.\n\nYour password for future applications is the following: #{temp_password}\n\nThanks,\n\nThe Team at Applyance",
        :to => [ { :email => self.account.email, :name => self.account.name } ],
        :from_email => "contact@applyance.co"
      }
      sending = m.messages.send(message)
    end

  end
end
