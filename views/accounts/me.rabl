object false

node do

  child @account => :account do
    extends 'accounts/_shallow'
  end

  child @reviewers => :reviewers do
    attributes :id, :scope, :created_at, :updated_at
    child :entity => :entity do
      extends 'entities/_shallow'
    end
  end

  child @applicant => :applicant do
    attributes :id, :phone_number, :created_at, :updated_at
    child :location => :location do
      extends 'locations/_shallow'
    end
  end

end
