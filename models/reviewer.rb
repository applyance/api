module Applyance
  class Reviewer < Sequel::Model

    many_to_one :entity, :class => :'Applyance::Entity'
    many_to_one :account, :class => :'Applyance::Account'

    one_to_many :notes, :class => :'Applyance::Note'
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
    def send_welcome_email(temp_password = nil)
      template = {
        :template => File.join('reviewers', 'welcome'),
        :locals => {
          :verify_digest => self.account.verify_digest,
          :temp_password => temp_password
        }
      }
      message = {
        :subject => "Welcome to Applyance",
        :to => [ { :email => self.account.email, :name => self.account.name } ],
        :merge_vars => [
          {
            "rcpt" => self.account.email,
            "vars" => [{ "content" => self.account.name, "name" => "name" }]
          }
        ]
      }
      Applyance::Lib::Emails::Sender::send_template(template, message)
    end

    # Notify reviewer that an application was received
    def send_application_received_email(application)

      citizen = self.entity.citizen_for_application(application)

      template = {
        :template => File.join('reviewers', 'application_received'),
        :locals => {
          :reviewer => self,
          :application => application,
          :citizen => citizen
        }
      }
      message = {
        :subject => "New Application",
        :to => [ { :email => self.account.email, :name => self.account.name } ],
        :merge_vars => [{
          "rcpt" => self.account.email,
          "vars" => [{ "content" => self.account.name, "name" => "name" }]
        }]
      }
      Applyance::Lib::Emails::Sender::send_template(template, message)

    end

    # Subscribe this user to mailchimp
    def subscribe_to_mailchimp

      api_key = Applyance::Server.settings.mailchimp_api_key
      list_id = Applyance::Server.settings.mailchimp_subscriber_list_id
      email = { "email" => self.account.email }
      merge_vars = {
        "groupings" => [
          {
            "name" => "Role",
            "groups" => ["Reviewer"]
          }
        ],
        "COMPANY" => self.entity.root_entity.name,
        "FNAME" => self.account.first_name,
        "LNAME" => self.account.last_name
      }

      puts "Subscribing to mailchimp [#{merge_vars}]."

      return unless Applyance::Server.production?

      begin
        mailchimp = Mailchimp::API.new(api_key)
        mailchimp.lists.subscribe(
          list_id,
          email,
          merge_vars,
          'html', # email type
          false, # double optin
          true, # update existing
          true, # replace interests
          false # send welcome
        )
      rescue => e
        puts "There was an error subscribing to mailchimp. Continuing anyway."
      end

    end

  end
end
