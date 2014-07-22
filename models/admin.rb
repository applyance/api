module Applyance
  class Admin < Sequel::Model

    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :account, :class => :'Applyance::Account'

    def after_create
      super

      # Make sure entity admins are full-access reviewers for
      # all sub units
      self.entity.units.each do |unit|
        Reviewer.make_from_admin(unit, self)
      end
    end

    # Welcome the new admin by way of email
    def send_welcome_email
      return if Applyance::Server.test?
      m = Mandrill::API.new(Applyance::Server.settings.mandrill_api_key)
      message = {
        :subject => "Welcome to Applyance",
        :from_name => "The Team at Applyance",
        :text => "Hello #{self.account.name},\n\nWelcome to Applyance. We're on an ambitious mission to replace grueling applications with a delightful experience. We hope you greatly enjoy what you see and use.\n\nIf you have any feedback, please let us know.\n\nWhen you get the chance, please verify your account by visiting this link: #{Applyance::Server.settings.client_url}/accounts/verify?code=#{self.account.verify_digest}.\n\nThanks,\n\nThe Team at Applyance",
        :to => [ { :email => self.account.email, :name => self.account.name } ],
        :from_email => "contact@applyance.co"
      }
      sending = m.messages.send(message)
    end
  end
end
