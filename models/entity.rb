class Entity < Sequel::Model
  one_to_many :members, :class => :EntityMember
  one_to_many :invitations, :class => :EntityMemberInvitation

  # Register a new entity with the specified account
  def self.register(account, params)
    entity = self.create(:name => params[:entity][:name])
    EntityMember.create(
      :entity_id => entity.id,
      :member_id => account.id,
      :role => "admin"
    )
    entity
  end
end

class EntityMember < Sequel::Model
  many_to_one :entity
  many_to_one :member, :class => :Account
  one_to_many :segments, :class => :EntityMemberSegment
end

class EntityMemberInvitation < Sequel::Model
  many_to_one :entity
end

class EntityMemberSegment < Sequel::Model
  many_to_one :entity
  many_to_one :member
end
