object false

node do

  child @account => :account do
    extends 'accounts/_shallow'
  end

  child @account.reviewers => :reviewers do
    attributes :id, :scope, :created_at, :updated_at
    child :entity => :entity do |entity|
      extends 'entities/_shallow'
      if entity.is_root?
        child :customer => :customer do
          extends 'entity_customers/_shallow'
        end
      else
        child entity.parent => :parent do
          extends 'entities/_shallow'
          child :customer => :customer do
            extends 'entity_customers/_shallow'
          end
        end
      end
    end
  end

  child @account.citizens => :citizens do
    attributes :id, :created_at, :updated_at
    child :entity => :entity do
      extends 'entities/_shallow'
    end
  end

end
