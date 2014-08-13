Sequel.migration do
  change do
    create_table(:addresses) do
      primary_key :id
      String :address_1, :text=>true
      String :address_2, :text=>true
      String :city, :text=>true
      String :state, :text=>true
      String :postal_code, :text=>true
      String :country, :text=>true
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:applications, :ignore_index_errors=>true) do
      primary_key :id
      String :digest, :text=>true, :null=>false
      DateTime :submitted_at
      DateTime :last_activity_at
      DateTime :created_at
      DateTime :updated_at
      
      index [:digest], :unique=>true
    end
    
    create_table(:attachments) do
      primary_key :id
      String :token, :text=>true, :null=>false
      String :name, :text=>true, :null=>false
      String :url, :text=>true, :null=>false
      String :content_type, :text=>true, :null=>false
      Integer :byte_size
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:coordinates) do
      primary_key :id
      Float :lat
      Float :lng
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:definitions, :ignore_index_errors=>true) do
      primary_key :id
      String :slug, :text=>true, :null=>false
      String :name, :text=>true, :null=>false
      String :label, :text=>true, :null=>false
      String :description, :text=>true
      String :type, :text=>true, :null=>false
      String :helper, :text=>true
      TrueClass :is_contextual, :default=>false
      TrueClass :is_sensitive, :default=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:slug], :unique=>true
    end
    
    create_table(:domains, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:name], :name=>:domains_name_key, :unique=>true
    end
    
    create_table(:errors) do
      primary_key :id
      String :name, :text=>true
      String :detail, :text=>true
      String :http_status_code, :text=>true
      String :backtrace, :text=>true
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:roles, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      
      index [:name], :name=>:roles_name_key, :unique=>true
    end
    
    create_table(:schema_info) do
      Integer :version, :default=>0, :null=>false
    end
    
    create_table(:accounts, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      String :email, :text=>true, :null=>false
      String :password_hash, :text=>true, :null=>false
      String :api_key, :text=>true, :null=>false
      TrueClass :is_verified, :default=>false
      String :verify_digest, :text=>true
      String :reset_digest, :text=>true
      foreign_key :avatar_id, :attachments, :key=>[:id]
      DateTime :created_at
      DateTime :updated_at
      
      index [:api_key], :unique=>true
      index [:email], :unique=>true
      index [:reset_digest], :name=>:accounts_reset_digest_key, :unique=>true
      index [:verify_digest], :name=>:accounts_verify_digest_key, :unique=>true
    end
    
    create_table(:application_activities) do
      primary_key :id
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      String :detail, :text=>true
      DateTime :activity_at
      String :object_type, :text=>true
      Integer :object_id
    end
    
    create_table(:blueprints, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :definition_id, :definitions, :key=>[:id]
      Integer :position, :null=>false
      TrueClass :is_required, :default=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:position]
    end
    
    create_table(:definitions_domains, :ignore_index_errors=>true) do
      foreign_key :definition_id, :definitions, :key=>[:id], :on_delete=>:cascade
      foreign_key :domain_id, :domains, :key=>[:id], :on_delete=>:cascade
      
      index [:definition_id], :name=>:definitions_domains_definition_id_key, :unique=>true
    end
    
    create_table(:locations) do
      primary_key :id
      foreign_key :coordinate_id, :coordinates, :key=>[:id], :on_delete=>:set_null
      foreign_key :address_id, :addresses, :key=>[:id], :on_delete=>:set_null
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:accounts_roles) do
      foreign_key :account_id, :accounts, :key=>[:id], :on_delete=>:cascade
      foreign_key :role_id, :roles, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:entities, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :domain_id, :domains, :key=>[:id], :on_delete=>:set_null
      foreign_key :parent_id, :entities, :key=>[:id], :on_delete=>:cascade
      foreign_key :logo_id, :attachments, :key=>[:id]
      foreign_key :location_id, :locations, :key=>[:id]
      String :name, :text=>true, :null=>false
      String :slug, :text=>true, :null=>false
      String :_slug, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:slug], :name=>:entities_slug_key, :unique=>true
    end
    
    create_table(:profiles, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :account_id, :accounts, :key=>[:id], :on_delete=>:cascade
      foreign_key :location_id, :locations, :key=>[:id], :on_delete=>:set_null
      String :phone_number, :text=>true
      DateTime :created_at
      DateTime :updated_at
      
      index [:account_id], :name=>:profiles_account_id_key, :unique=>true
    end
    
    create_table(:applications_entities) do
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:blueprints_entities, :ignore_index_errors=>true) do
      foreign_key :blueprint_id, :blueprints, :key=>[:id], :on_delete=>:cascade
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      
      index [:blueprint_id], :name=>:blueprints_entities_blueprint_id_key, :unique=>true
    end
    
    create_table(:datums) do
      primary_key :id
      foreign_key :definition_id, :definitions, :key=>[:id], :on_delete=>:cascade
      String :detail, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      foreign_key :profile_id, :profiles, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:definitions_entities, :ignore_index_errors=>true) do
      foreign_key :definition_id, :definitions, :key=>[:id], :on_delete=>:cascade
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      
      index [:definition_id], :name=>:definitions_entities_definition_id_key, :unique=>true
    end
    
    create_table(:labels) do
      primary_key :id
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      String :name, :text=>true, :null=>false
      String :color, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:pipelines) do
      primary_key :id
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      String :name, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:reviewer_invites, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      String :email, :text=>true, :null=>false
      String :claim_digest, :text=>true, :null=>false
      String :scope, :default=>"limited", :text=>true, :null=>false
      String :status, :default=>"open", :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:claim_digest], :unique=>true
      index [:entity_id, :email], :unique=>true
    end
    
    create_table(:reviewers, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      foreign_key :account_id, :accounts, :key=>[:id], :on_delete=>:cascade
      String :scope, :default=>"limited", :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:entity_id, :account_id], :unique=>true
    end
    
    create_table(:spots) do
      primary_key :id
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      String :name, :text=>true, :null=>false
      String :detail, :text=>true
      String :status, :default=>"active", :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      String :slug, :text=>true
      String :_slug, :text=>true
    end
    
    create_table(:templates) do
      primary_key :id
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
      String :subject, :text=>true, :null=>false
      String :message, :text=>true
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:applications_reviewers) do
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      foreign_key :reviewer_id, :reviewers, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:applications_spots) do
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      foreign_key :spot_id, :spots, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:attachments_datums) do
      foreign_key :datum_id, :datums, :key=>[:id], :on_delete=>:cascade
      foreign_key :attachment_id, :attachments, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:attachments_templates) do
      foreign_key :attachment_id, :attachments, :key=>[:id], :on_delete=>:cascade
      foreign_key :template_id, :templates, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:blueprints_spots, :ignore_index_errors=>true) do
      foreign_key :blueprint_id, :blueprints, :key=>[:id], :on_delete=>:cascade
      foreign_key :spot_id, :spots, :key=>[:id], :on_delete=>:cascade
      
      index [:blueprint_id], :name=>:blueprints_spots_blueprint_id_key, :unique=>true
    end
    
    create_table(:fields) do
      primary_key :id
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      foreign_key :datum_id, :datums, :key=>[:id], :on_delete=>:set_null
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:notes) do
      primary_key :id
      foreign_key :reviewer_id, :reviewers, :key=>[:id], :on_delete=>:set_null
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      String :note, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:segments) do
      primary_key :id
      foreign_key :reviewer_id, :reviewers, :key=>[:id], :on_delete=>:cascade
      String :name, :text=>true, :null=>false
      String :dsl, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:stages, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :pipeline_id, :pipelines, :key=>[:id], :on_delete=>:cascade
      String :name, :text=>true, :null=>false
      Integer :position, :null=>false
      DateTime :created_at
      DateTime :updated_at
      
      index [:pipeline_id, :position], :unique=>true
    end
    
    create_table(:citizens) do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      foreign_key :stage_id, :stages, :key=>[:id], :on_delete=>:set_null
      foreign_key :account_id, :accounts, :key=>[:id], :on_delete=>:cascade
      foreign_key :entity_id, :entities, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:applications_citizens) do
      foreign_key :application_id, :applications, :key=>[:id], :on_delete=>:cascade
      foreign_key :citizen_id, :citizens, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:citizens_labels) do
      foreign_key :citizen_id, :citizens, :key=>[:id], :on_delete=>:cascade
      foreign_key :label_id, :labels, :key=>[:id], :on_delete=>:cascade
    end
    
    create_table(:ratings, :ignore_index_errors=>true) do
      primary_key :id
      foreign_key :account_id, :accounts, :key=>[:id], :on_delete=>:cascade
      Integer :rating, :null=>false
      DateTime :created_at
      DateTime :updated_at
      foreign_key :citizen_id, :citizens, :key=>[:id], :on_delete=>:cascade
      
      index [:citizen_id, :account_id], :unique=>true
    end
    
    create_table(:threads, :ignore_index_errors=>true) do
      primary_key :id
      String :reply_digest, :text=>true, :null=>false
      String :subject, :text=>true, :null=>false
      DateTime :created_at
      DateTime :updated_at
      foreign_key :citizen_id, :citizens, :key=>[:id], :on_delete=>:cascade
      
      index [:reply_digest], :unique=>true
    end
    
    create_table(:messages) do
      primary_key :id
      foreign_key :thread_id, :threads, :key=>[:id], :on_delete=>:cascade
      foreign_key :sender_id, :accounts, :key=>[:id], :on_delete=>:cascade
      String :message, :text=>true
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:attachments_messages) do
      foreign_key :attachment_id, :attachments, :key=>[:id], :on_delete=>:cascade
      foreign_key :message_id, :messages, :key=>[:id], :on_delete=>:cascade
    end
  end
end
