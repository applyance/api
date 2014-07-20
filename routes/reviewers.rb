module Applyance
  module Routing
    module Reviewers
      def self.registered(app)

        # Protection to admins or reviewers
        to_full_access_reviewers = lambda do |unit|
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => "full").collect(&:account_id).include?(account.id)
          end
        end

        # Protection to admins or reviewers
        to_full_access_reviewers_or_self = lambda do |reviewer|
          lambda do |account|
            return true if account.id == reviewer.account_id
            reviewer.unit.reviewers_dataset.where(:access_level => "full").collect(&:account_id).include?(account.id)
          end
        end

        # List reviewers for a unit
        app.get '/units/:id/reviewers', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! to_full_access_reviewers(@unit)
          @reviewers = @unit.reviewers
          rabl :'reviewers/index'
        end

        # Get reviewer by Id
        app.get '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params[:id])
          rabl :'reviewers/show'
        end

        # Update reviewer by Id
        app.put '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params[:id])
          protected! to_full_access_reviewers(@reviewer)
          @reviewer.update_fields(params, [:access_level], :missing => :skip)
          rabl :'reviewers/show'
        end

        # Delete a reviewer by Id
        app.delete '/reviewers/:id', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params[:id])
          protected! to_full_access_reviewers_or_self(@reviewer)

          @reviewer.segments_dataset.destroy
          @reviewer.ratings_dataset.destroy
          @reviewer.notes_dataset.destroy
          @reviewer.destroy

          204
        end

      end
    end
  end
end
