module Applyance
  class Profile < Sequel::Model

    include Applyance::Lib::Locations

    many_to_one :account, :class => :'Applyance::Account'
    one_to_many :datums, :class => :'Applyance::Datum'

    # Welcome the new reviewer by way of email
    def send_welcome_email(temp_password)

      template = {
        :template => File.join('profiles', 'welcome'),
        :locals => {
          :temp_password => temp_password
        }
      }
      message = {
        :subject => "Welcome to Applyance",
        :to => [ { :email => self.account.email, :name => self.account.name } ],
        :merge_vars => [{
          "rcpt" => self.account.email,
          "vars" => [{ "content" => self.account.name, "name" => "name" }]
        }]
      }
      Applyance::Lib::Emails::Sender::send_template(template, message)

    end

  end
end
