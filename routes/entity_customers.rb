module Applyance
  module Routing
    module EntityCustomers

      def self.registered(app)

        # List the customer of an entity
        # Only admins can do this
        app.get '/entities/:id/customer', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_entity_admins(@entity)
          @entity_customer = @entity.customer
          rabl :'entity_customers/show'
        end

        # Create a new entity customer
        app.post '/entities/:id/customers', :provides => [:json] do
          @entity = Entity.first(:id => params[:id])
          protected! app.to_entity_admins(@entity)
          unless @entity.is_root?
            raise BadRequestError.new({ detail: "Must create customer on root entity only. "})
          end
          @entity_customer = EntityCustomer.make(params)
          status 201
          rabl :'entity_customers/show'
        end

        # Retrieve the specified entity customer
        app.get '/entities/customers/:id', :provides => [:json] do
          @entity_customer = EntityCustomer.first(:id => params[:id])
          protected! app.to_entity_admins(@entity_customer.entity)
          rabl :'entity_customers/show'
        end

        # Update an entity customer by Id
        # Must be an admin
        app.put '/entities/customers/:id', :provides => [:json] do
          @entity_customer = EntityCustomer.first(:id => params['id'])
          protected! app.to_entity_admins(@entity_customer.entity)
          @entity_customer.make_update(params)
          rabl :'entity_customers/show'
        end

        # Delete an entity customer by Id
        # Must be an admin
        app.delete '/entities/customers/:id', :provides => [:json] do
          @entity_customer = EntityCustomer.first(:id => params['id'])
          protected! app.to_entity_admins(@entity_customer.entity)
          @entity_customer.destroy
          204
        end

      end
    end
  end
end
