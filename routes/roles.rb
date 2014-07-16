module Applyance
  module Routing
    module Roles
      def self.registered(app)

        # Roles index
        app.get '/roles', :provides => [:json] do
          @roles = Role.all
          rabl :'roles/index'
        end

        # Show role by Id
        app.get '/roles/:id', :provides => [:json] do
          @role = Role.first(:id => params[:id])
          rable :'roles/show'
        end

      end
    end
  end
end
