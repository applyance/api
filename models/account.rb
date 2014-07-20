module Applyance
  class Account < Sequel::Model

    include Applyance::Lib::Attachments
    include Applyance::Lib::Tokens

    many_to_many :roles, :class => :'Applyance::Role'
    many_to_one :avatar, :class => :'Applyance::Attachment'
    one_to_many :answers, :class => :'Applyance::Answer'

    def validate
      super
      validates_presence [:name, :email]
      validates_unique :email
    end

    # Check if this account has the named role
    def has_role?(name)
      self.roles_dataset.where(:name => name).count > 0
    end

    # Register the account with the specified role
    def self.make(role, params)
      account = self.new
      account.set_fields(params, [:name, :email], :missing => :skip)
      account.set_token(:api_key)
      account.set_token(:verify_digest)
      account.set(:password_hash => BCrypt::Password.create(params[:password]))
      account.save

      account.add_role(Role.first(:name => role))
      account
    end

    # Convenience method for making if does not exist
    def self.first_or_make(role, params)
      account = self.first(:email => params[:email])
      if account
        account.add_role(Role.first(:name => role)) unless account.has_role?(role)
        return account
      end
      self.make(role, params)
    end

    # Handle registration
    def self.register(role, params)
      if params[:password].empty?
        raise BadRequestError({ :detail => "Password is required." })
      end
      self.make(role, params[:account])

      # TODO: Send registration email
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
      if params[:new_password].length == 0
        raise BadRequestError.new({ :detail => "You must enter a new password." })
      end

      self.update(:password_hash => BCrypt::Password.create(params[:new_password]))
    end

    # Password change request from the user
    def change_password(params)
      # Make sure current password is correct
      unless BCrypt::Password.new(self.password_hash) == params[:password]
        raise BadRequestError.new({ :detail => "Incorrect password." })
      end

      # Make sure the new password actually was entered
      if params[:new_password].length == 0
        raise BadRequestError.new({ :detail => "You must enter a new password." })
      end

      self.update(:password_hash => BCrypt::Password.create(params[:new_password]))
    end

    # Used for a user changing their email
    def change_email(params)
      # Make sure current password is correct
      unless BCrypt::Password.new(self.password_hash) == params[:password]
        raise BadRequestError.new({ :detail => "Incorrect password." })
      end

      # Make sure the new email actually was entered
      if params[:email].length == 0
        raise BadRequestError.new({ :detail => "You must enter a new email." })
      end

      self.update(:email => params[:email], :is_verified => false)

      # TODO: Send notification to verify new email address

      params[:email]
    end

    # Used for a user verifying their email
    def verify_email(params)
      # Make sure the verify digest is correct
      unless params[:verify_digest] == self.verify_digest
        raise BadRequestError({ :detail => "Invalid verify digest." })
      end
      self.update(:is_verified => true)
      true
    end

    # Authorize via email and password
    def self.authenticate(params)
      account = self.first(
        :email => params[:email],
        :password_hash => BCrypt::Password.new(params[:password]))

      # Check for an existing account
      if account.nil?
        raise BadRequestError.new({ :detail => "Invalid authentication credentials." })
      end

      account
    end

  end
end
