attributes :id, :email, :claim_digest, :status, :created_at, :updated_at

child :entity do
  extends 'entities/_single'
end
