module Applyance
  module Routing
    module Entities
      def self.registered(app)

        # Show an entity specified by Id
        app.get '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          @account = protected!(lambda { |account| @entity.members.collect(&:member_id).include?(account.id) })
          rabl :'entities/show'
        end

        # Update an entity specified by Id
        app.put '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          @account = protected!(lambda { |account| @entity.members.collect(&:member_id).include?(account.id) })
          @entity.update(params.slice(:name))
          rabl :'entities/show'
        end

        # Delete the entity if an admin of the entity
        app.delete '/entities/:id', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          @account = protected!(lambda do |account|
            member = @entity.members_dataset.first(:member_id => account.id)
            !member.nil? and member.role == "admin"
          end)

          @entity.members_dataset.destroy
          @entity.destroy

          204
        end

      end
    end
  end
end
