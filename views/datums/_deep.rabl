attributes :id, :detail, :created_at, :updated_at

child :profile => :profile do
  extends 'profiles/_shallow'
end

child :definition => :definition do
  extends 'definitions/_shallow'
end

child :attachments => :attachments do
  extends 'attachments/_shallow'
end
