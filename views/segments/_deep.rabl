attributes :id, :name, :dsl, :created_at, :updated_at

child :reviewer => :reviewer do
  extends 'reviewers/_shallow'
end
