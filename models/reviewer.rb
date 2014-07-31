module Applyance
  class Reviewer < Sequel::Model

    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :account, :class => :'Applyance::Account'

    one_to_many :notes, :class => :'Applyance::Note'
    one_to_many :ratings, :class => :'Applyance::Rating'
    one_to_many :segments, :class => :'Applyance::Segment'

    def after_create
      super

      # After creating a new reviewer, go through all child entities and CREATE
      # this new reviewer as a reviewer of all subentities. This should start a chain
      # reaction of CREATE hooks until all reviewers are made
      self.entity.entities.each do |entity|
        Reviewer.create(
          :entity_id => entity.id,
          :account_id => self.account_id,
          :scope => self.scope
        )
      end
    end

    def after_update
      super

      # After updating a reviewer, go through all child entities and UPDATE
      # these reviewers as a reviewer of all subentities. This should start a chain
      # reaction of UPDATE hooks until all reviewers are updated
      self.entity.entities.each do |entity|
        entity.reviewers_dataset.where(:account_id => self.account_id).update(:scope => self.scope)
      end
    end

    def after_destroy
      super

      # After updating a reviewer, go through all child entities and DESTROY
      # these reviewers of all subentities. This should start a chain
      # reaction of DESTROY hooks until all reviewers are updated
      self.entity.entities.each do |entity|
        entity.reviewers_dataset.where(:account_id => self.account_id).destroy
      end
    end

    # Welcome the new reviewer by way of email
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
