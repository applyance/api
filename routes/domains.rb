module Applyance
  module Routing
    module Domains
      def self.registered(app)

        # List domains
        app.get '/domains', :provides => [:json] do
          @domains = Domain.all
          rabl :'domains/index'
        end

        # Create a new domain
        app.post '/domains', :provides => [:json] do
          protected!
          @domain = Domain.new
          @domain.set_fields(params, ['name'], :missing => :skip)
          @domain.save
          status 201
          rabl :'domains/show'
        end

        # Get domain by Id
        app.get '/domains/:id', :provides => [:json] do
          key = (params['id'] =~ /^\d+$/) ? :id : :slug
          @domain = Domain.first(key => params['id'])

          if @domain.nil?
            raise BadRequestError.new({ detail: "Domain not found." })
          end

          rabl :'domains/show'
        end

        # Update a domain by Id
        app.put '/domains/:id', :provides => [:json] do
          protected!
          @domain = Domain.first(:id => params['id'])
          @domain.update_fields(params, ['name'], :missing => :skip)
          rabl :'domains/show'
        end

        # Delete a domain by Id
        app.delete '/domains/:id', :provides => [:json] do
          protected!
          @domain = Domain.first(:id => params['id'])

          @domain.definitions_dataset.destroy
          @domain.destroy
          204
        end

      end
    end
  end
end
