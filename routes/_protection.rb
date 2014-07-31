module Applyance
  module Routing
    module Protection

      # Protection for current account only
      def to_account_id(id)
        lambda { |account| account.id == id.to_i }
      end

      # Protection for current account only
      def to_account(target)
        lambda { |account| account.id == target.id }
      end

      # Protection to admins of entity
      def to_entity_admins(entity)
        lambda do |account|
          entity.reviewers_dataset.where(:scope => "admin").collect(&:account_id).include?(account.id)
        end
      end

      # Protection to reviewers of entity
      def to_entity_reviewers(entity)
        lambda do |account|
          entity.reviewers.collect(&:account_id).include?(account.id)
        end
      end

      # Protection to application reviewers
      def to_application_reviewers(application)
        lambda do |account|
          return true if application.spots.any? { |s| s.entity.reviewers.collect(&:account_id).include?(account.id) }
          application.entities.any? { |e| e.reviewers.collect(&:account_id).include?(account.id)  }
        end
      end

      # Protection to reviewers or self
      def to_application_reviewers_or_self(application)
        lambda do |account|
          return true if account.id == application.applicant.account_id
          to_reviewers_of_application(application).(account)
        end
      end

      # Protection to full-access reviewers
      def to_field_reviewers_or_self(field)
        lambda do |account|
          return true if field.datum.applicant.account_id == account.id
          field.application.spots.any? { |spot| spot.entity.reviewers.collect(&:account_id).include?(account.id) }
        end
      end

    end
  end
end
