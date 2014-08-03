Sequel.migration do
  change do

    # Create errors
    create_table(:errors) do
      primary_key :id

      String :name
      String :detail
      String :http_status_code
      String :backtrace

      DateTime :created_at
      DateTime :updated_at
    end

    # Create addresses
    create_table(:addresses) do
      primary_key :id

      String :address_1
      String :address_2
      String :city
      String :state
      String :postal_code
      String :country

      DateTime :created_at
      DateTime :updated_at
    end

    # Create coordinates
    create_table(:coordinates) do
      primary_key :id

      Float :lat
      Float :lng

      DateTime :created_at
      DateTime :updated_at
    end

    # Create locations
    create_table(:locations) do
      primary_key :id

      foreign_key :coordinate_id, :coordinates, :on_delete => :set_null
      foreign_key :address_id, :addresses, :on_delete => :set_null

      DateTime :created_at
      DateTime :updated_at
    end

    # Create attachments
    create_table(:attachments) do
      primary_key :id

      String :token, :null => false
      String :name, :null => false
      String :url, :null => false
      String :content_type, :null => false
      Integer :byte_size

      DateTime :created_at
      DateTime :updated_at
    end

    # Create domains
    create_table(:domains) do
      primary_key :id

      String :name, :null => false, :unique => true

      DateTime :created_at
      DateTime :updated_at
    end

    # Create roles
    create_table(:roles) do
      primary_key :id
      String :name, :null => false, :unique => true
    end

    # Create accounts
    create_table(:accounts) do
      primary_key :id

      String :name, :null => false
      String :email, :null => false, :index => { :unique => true }
      String :password_hash, :null => false
      String :api_key, :null => false, :index => { :unique => true }
      TrueClass :is_verified, :default => false

      String :verify_digest, :unique => true
      String :reset_digest, :unique => true

      foreign_key :avatar_id, :attachments

      DateTime :created_at
      DateTime :updated_at
    end

    # Create account role relationship
    create_table(:accounts_roles) do
      foreign_key :account_id, :accounts, :on_delete => :cascade
      foreign_key :role_id, :roles, :on_delete => :cascade
    end

    # Create applicants
    create_table(:applicants) do
      primary_key :id

      foreign_key :account_id, :accounts, :on_delete => :cascade, :unique => true
      foreign_key :location_id, :locations, :on_delete => :set_null

      String :phone_number

      DateTime :created_at
      DateTime :updated_at
    end

    # Create entities
    create_table(:entities) do
      primary_key :id

      foreign_key :domain_id, :domains, :null => true, :on_delete => :set_null
      foreign_key :parent_id, :entities, :null => true, :on_delete => :cascade

      foreign_key :logo_id, :attachments
      foreign_key :location_id, :locations
      String :name, :null => false
      String :slug, :null => false, :unique => true
      String :'_slug', :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create reviewers
    create_table(:reviewers) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade
      foreign_key :account_id, :accounts, :on_delete => :cascade

      String :scope, :null => false, :default => "limited"

      DateTime :created_at
      DateTime :updated_at

      index [:entity_id, :account_id], :unique => true
    end

    # Create reviewer invites
    create_table(:reviewer_invites) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade

      String :email, :null => false
      String :claim_digest, :null => false, :index => { :unique => true }
      String :scope, :null => false, :default => "limited"
      String :status, :null => false, :default => "open"

      DateTime :created_at
      DateTime :updated_at

      index [:entity_id, :email], :unique => true
    end

    # Create spots
    create_table(:spots) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade
      String :name, :null => false
      String :detail, :text => true
      String :status, :null => false, :default => "active"

      DateTime :created_at
      DateTime :updated_at
    end

    # Create templates
    create_table(:templates) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade
      String :subject, :null => false
      String :message, :text => true

      DateTime :created_at
      DateTime :updated_at
    end

    # Create template attachments
    create_table(:attachments_templates) do
      foreign_key :attachment_id, :attachments, :on_delete => :cascade
      foreign_key :template_id, :templates, :on_delete => :cascade
    end

    # Create pipelines
    create_table(:pipelines) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade
      String :name, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create stages
    create_table(:stages) do
      primary_key :id

      foreign_key :pipeline_id, :pipelines, :on_delete => :cascade
      String :name, :null => false
      Integer :position, :null => false

      DateTime :created_at
      DateTime :updated_at

      index [:pipeline_id, :position], :unique => true
    end

    # Create labels
    create_table(:labels) do
      primary_key :id

      foreign_key :entity_id, :entities, :on_delete => :cascade
      String :name, :null => false
      String :color, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create segments
    create_table(:segments) do
      primary_key :id

      foreign_key :reviewer_id, :reviewers, :on_delete => :cascade
      String :name, :null => false
      String :dsl, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create applications
    create_table(:applications) do
      primary_key :id

      foreign_key :applicant_id, :applicants, :on_delete => :set_null
      foreign_key :stage_id, :stages, :null => true, :on_delete => :set_null

      String :digest, :null => false, :index => { :unique => true }

      DateTime :submitted_at
      DateTime :last_activity_at
      DateTime :created_at
      DateTime :updated_at
    end

    # Create application spots
    create_table(:applications_spots) do
      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :spot_id, :spots, :on_delete => :cascade
    end

    # Create application entities
    create_table(:applications_entities) do
      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :entity_id, :entities, :on_delete => :cascade
    end

    # Create application reviewers
    create_table(:applications_reviewers) do
      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :reviewer_id, :reviewers, :on_delete => :cascade
    end

    # Create application labels
    create_table(:applications_labels) do
      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :label_id, :labels, :on_delete => :cascade
    end

    # Create application activities
    create_table(:application_activities) do
      primary_key :id
      foreign_key :application_id, :applications, :on_delete => :cascade
      String :detail, :text => true
      DateTime :activity_at
      String :object_type
      Integer :object_id
    end

    # Create threads
    create_table(:threads) do
      primary_key :id

      foreign_key :application_id, :applications, :on_delete => :cascade

      String :reply_digest, :null => false, :index => { :unique => true }
      String :subject, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create messages
    create_table(:messages) do
      primary_key :id

      foreign_key :thread_id, :threads, :on_delete => :cascade
      foreign_key :sender_id, :accounts, :on_delete => :cascade

      String :message, :text => true

      DateTime :created_at
      DateTime :updated_at
    end

    # Create message attachments
    create_table(:attachments_messages) do
      foreign_key :attachment_id, :attachments, :on_delete => :cascade
      foreign_key :message_id, :messages, :on_delete => :cascade
    end

    # Create notes
    create_table(:notes) do
      primary_key :id

      foreign_key :reviewer_id, :reviewers, :on_delete => :set_null
      foreign_key :application_id, :applications, :on_delete => :cascade

      String :note, :text => true, :null => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Create ratings
    create_table(:ratings) do
      primary_key :id

      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :account_id, :accounts, :on_delete => :cascade

      Integer :rating, :null => false

      DateTime :created_at
      DateTime :updated_at

      index [:application_id, :account_id], :unique => true
    end

    # Create definitions
    create_table(:definitions) do
      primary_key :id

      String :name, :null => false, :index => { :unique => true }
      String :label, :null => false
      String :description, :text => true
      String :type, :null => false
      String :helper, :text => true
      TrueClass :is_contextual, :default => false
      TrueClass :is_sensitive, :default => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Domain definitions
    create_table(:definitions_domains) do
      foreign_key :definition_id, :definitions, :on_delete => :cascade, :unique => true
      foreign_key :domain_id, :domains, :on_delete => :cascade
    end

    # Entity definitions
    create_table(:definitions_entities) do
      foreign_key :definition_id, :definitions, :on_delete => :cascade, :unique => true
      foreign_key :entity_id, :entities, :on_delete => :cascade
    end

    # Create blueprints
    create_table(:blueprints) do
      primary_key :id

      foreign_key :definition_id, :definitions

      Integer :position, :null => false, :index => true
      TrueClass :is_required, :default => false

      DateTime :created_at
      DateTime :updated_at
    end

    # Spot blueprints
    create_table(:blueprints_spots) do
      foreign_key :blueprint_id, :blueprints, :on_delete => :cascade, :unique => true
      foreign_key :spot_id, :spots, :on_delete => :cascade
    end

    # Entity blueprints
    create_table(:blueprints_entities) do
      foreign_key :blueprint_id, :blueprints, :on_delete => :cascade, :unique => true
      foreign_key :entity_id, :entities, :on_delete => :cascade
    end

    # Create datums
    create_table(:datums) do
      primary_key :id

      foreign_key :applicant_id, :applicants, :on_delete => :cascade
      foreign_key :definition_id, :definitions, :on_delete => :cascade
      String :detail, :null => false, :text => true

      DateTime :created_at
      DateTime :updated_at
    end

    # Create datum attachments
    create_table(:attachments_datums) do
      foreign_key :datum_id, :datums, :on_delete => :cascade
      foreign_key :attachment_id, :attachments, :on_delete => :cascade
    end

    # Create fields
    create_table(:fields) do
      primary_key :id

      foreign_key :application_id, :applications, :on_delete => :cascade
      foreign_key :datum_id, :datums, :on_delete => :set_null

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
