object false

node do

  child @account => :account do
    extends 'accounts/_shallow'
  end

  child @admins => :admins do
    attributes :id, :created_at, :updated_at
    child :entity => :entity do
      extends 'entities/_shallow'
    end
  end

  child @reviewers => :reviewers do
    attributes :id, :access_level, :is_entity_admin, :created_at, :updated_at
    child :unit => :unit do
      extends 'units/_shallow'
    end
  end

end
