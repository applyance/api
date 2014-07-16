require 'bcrypt'

class Role < Sequel::Model
  many_to_many :accounts
end

class Account < Sequel::Model
  many_to_many :roles
  one_to_one :entity_member

  # Register the account with the specified role
  def self.register(role, params)
    account = self.create(
      :name  => params[:account][:name],
      :email => params[:account][:email],
      :password_hash => BCrypt::Password.create(params[:account][:password]),
      :api_key => self.generate_token(:api_key),
      :verify_digest => self.generate_token(:verify_digest)
    )
    account.add_role(Role.first(:name => role))

    # TODO: Send registration email

    account
  end

  # Reset password request from the user
  def reset_password
    self.update(:reset_digest => self.generate_token(:reset_digest))

    # TODO: Send email with reset digest
  end

  # Password change request from the user
  def change_password(params)
    # Make sure the reset digest is correct
    unless params[:reset_digest] == self.reset_digest
      raise BadRequestError.new({ :detail => "Invalid reset digest." })
    end

    # Make sure current password is correct
    unless BCrypt::Password.new(self.password_hash) == params[:password]
      raise BadRequestError.new({ :detail => "Incorrect password." })
    end

    # Make sure the new password actually was entered
    if params[:new_password].length == 0
      raise BadRequestError.new({ :detail => "You must enter a new password." })
    end

    self.update(:password_hash => BCrypt::Password.create(params[:new_password]))
    new_password
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
  def self.authorize(params)
    account = self.first(
      :email => params[:email],
      :password_hash => BCrypt::Password.new(params[:password]))

    # Check for an existing account
    if account.nil?
      raise BadRequestError.new({ :detail => "Invalid authentication credentials." })
    end

    account
  end

  # Generate a token and make sure it is unique based on the key specified
  def self.generate_token(key)
    token = ""
    loop do
      token = SecureRandom.urlsafe_base64(nil, false)
      break token unless self.where(key => token).count > 0
    end
    token
  end
end
