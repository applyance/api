attributes :id, :email, :claim_digest, :status, :access_level, :created_at, :updated_at

child :unit do
  extends 'units/_shallow'
end
