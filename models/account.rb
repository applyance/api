module Applyance
  class Account < Sequel::Model

    include Applyance::Lib::Attachments
    include Applyance::Lib::Tokens

    many_to_many :roles, :class => :'Applyance::Role'
    many_to_one :avatar, :class => :'Applyance::Attachment'
    one_to_many :datums, :class => :'Applyance::Datum'
    one_to_many :admins, :class => :'Applyance::Admin'
    one_to_many :reviewers, :class => :'Applyance::Reviewer'

    def validate
      super
      validates_presence [:name, :email]
      validates_unique :email
      validates_min_length 2, :name
    end

    # Check if this account has the named role
    def has_role?(name)
      self.roles_dataset.where(:name => name).count > 0
    end

    # Make the account with the specified role
    def self.make(role, params)
      account = self.first(:email => params['email'])
      if account
        account.add_role(Role.first(:name => role)) unless account.has_role?(role)
        return account
      end

      account = self.new
      account.set_fields(params, ['name', 'email'], :missing => :skip)
      account.set_token(:api_key)
      account.set_token(:verify_digest)
      account.set(:password_hash => BCrypt::Password.create(params['password']))
      account.save

      account.add_role(Role.first(:name => role))
      account
    end

    # Authorize via email and password
    def self.authenticate(params)
      account = self.first(:email => params['email'])

      # Check for an existing account
      if account.nil?
        raise BadRequestError.new({ :detail => "Account not found with the email specified." })
      end

      # Check password
      unless BCrypt::Password.new(account.password_hash) == params['password']
        raise BadRequestError.new({ :detail => "Incorrect password." })
      end

      account
    end

    # Reset password request from the user
    def reset_password
      self.update(:reset_digest => self.generate_token(:reset_digest))

      # TODO: Send email with reset digest
    end

    # Set password for the user
    # This is after a reset password request
    def set_password(params)
      # Make sure the new password actually was entered
      if params['new_password'].length == 0
        raise BadRequestError.new({ :detail => "You must enter a new password." })
      end

      self.update(:password_hash => BCrypt::Password.create(params['new_password']))
    end

    # Update account stuff
    def handle_update(params)
      self.update_fields(params, ['name'], :missing => :skip)
      self.attach(params['avatar'], :avatar)
      self.change_password(params) unless params['new_password'].nil?
      self.change_email(params) unless params['email'].nil?
    end

    # Password change request from the user
    def change_password(params)
      # Make sure current password is correct
      unless BCrypt::Password.new(self.password_hash) == params['password']
        raise BadRequestError.new({ :detail => "Incorrect password." })
      end

      # Make sure the new password actually was entered
      if params['new_password'].length == 0
        raise BadRequestError.new({ :detail => "You must enter a new password." })
      end

      self.update(:password_hash => BCrypt::Password.create(params['new_password']))
    end

    # Used for a user changing their email
    def change_email(params)
      # Make sure current password is correct
      unless BCrypt::Password.new(self.password_hash) == params['password']
        raise BadRequestError.new({ :detail => "Incorrect password." })
      end

      # Make sure the new email actually was entered
      if params['email'].length == 0
        raise BadRequestError.new({ :detail => "You must enter a new email." })
      end

      self.update(:email => params['email'], :is_verified => false)

      # TODO: Send notification to verify new email address

      params['email']
    end

    # Used for a user verifying their email
    def verify_email(params)
      self.update(:is_verified => true)
      true
    end

  end
end
