FactoryGirl.define do

  to_create { |i| i.save }

  factory :domain, class: Applyance::Domain do
    sequence(:name) { |n| "Domain #{n}" }

    trait :with_definition do
      after(:create) do |domain|
        domain.add_definition(create(:definition))
      end
    end

    factory :domain_with_definition, traits: [:with_definition]
  end

  factory :role, class: Applyance::Role do
    name "admin"
  end

  factory :account, class: Applyance::Account do

    name "Stephen Watkins"
    sequence(:email) { |n| "email#{n}@gmail.com" }
    password_hash { BCrypt::Password.create("test") }
    api_key { SecureRandom.urlsafe_base64(nil, false) }
    is_verified false
    verify_digest { SecureRandom.urlsafe_base64(nil, false) }
    reset_digest { SecureRandom.urlsafe_base64(nil, false) }

    trait :chief do
      after(:create) { |account| account.add_role(Applyance::Role.first(:name => "chief")) }
    end
    trait :applicant do
      after(:create) { |account| account.add_role(Applyance::Role.first(:name => "applicant")) }
    end
    trait :admin do
      after(:create) do |account|
        account.add_role(Applyance::Role.first(:name => "admin"))
        account.add_role(Applyance::Role.first(:name => "reviewer"))
      end
    end
    trait :reviewer do
      after(:create) { |account| account.add_role(Applyance::Role.first(:name => "reviewer")) }
    end

    factory :chief_account, traits: [:chief]
    factory :admin_account, traits: [:admin]
    factory :reviewer_account, traits: [:reviewer]
    factory :applicant_account, traits: [:applicant]

  end

  factory :entity, class: Applyance::Entity do
    name "The Iron Yard"
    domain

    trait :with_admin do
      after(:create) do |entity|
        entity.add_admin(create(:admin))
      end
    end

    trait :with_admin_invite do
      after(:create) do |entity|
        entity.add_admin_invite(create(:admin_invite))
      end
    end

    factory :entity_with_admin, traits: [:with_admin]
    factory :entity_with_admin_invite, traits: [:with_admin, :with_admin_invite]
  end

  factory :admin, class: Applyance::Admin do
    association :account, factory: :chief_account
    entity
    access_level "owner"
  end

  factory :admin_invite, class: Applyance::AdminInvite do
    entity
    sequence(:email) { |n| "email#{n}@gmail.com" }
    claim_digest { SecureRandom.urlsafe_base64(nil, false) }
    status "open"
    access_level "owner"
  end

  factory :unit, class: Applyance::Unit do
    name "Building 1"
    association :entity, factory: :entity_with_admin

    trait :with_reviewer do
      after(:create) do |unit|
        unit.add_reviewer(create(:reviewer))
      end
    end

    trait :with_reviewer_invite do
      after(:create) do |unit|
        unit.add_reviewer_invite(create(:reviewer_invite))
      end
    end

    trait :with_definition do
      after(:create) do |unit|
        unit.add_definition(create(:definition))
      end
    end

    factory :unit_with_reviewer, traits: [:with_reviewer]
    factory :unit_with_reviewer_invite, traits: [:with_reviewer, :with_reviewer_invite]
    factory :unit_with_definition, traits: [:with_reviewer, :with_definition]
  end

  factory :reviewer, class: Applyance::Reviewer do
    association :account, factory: :chief_account
    unit
    access_level "full"
  end

  factory :reviewer_invite, class: Applyance::ReviewerInvite do
    unit
    sequence(:email) { |n| "email#{n}@gmail.com" }
    access_level "full"
    claim_digest { SecureRandom.urlsafe_base64(nil, false) }
    status "open"
  end

  factory :spot, class: Applyance::Spot do
    name "Spot 1"
    association :unit, factory: :unit_with_reviewer
    detail "Detail..."
    status "open"
  end

  factory :definition, class: Applyance::Definition do
    sequence(:label) { |n| "Definition #{n}" }
    description "Description..."
    type "text"
  end

  factory :blueprint, class: Applyance::Blueprint do
    definition
    sequence(:position) { |n| n }
    is_required false

    trait :with_unit do
      after(:create) do |blueprint|
        create(:unit_with_reviewer).add_blueprint(blueprint)
      end
    end

    trait :with_entity do
      after(:create) do |blueprint|
        create(:entity_with_admin).add_blueprint(blueprint)
      end
    end

    trait :with_spot do
      after(:create) do |blueprint|
        create(:spot).add_blueprint(blueprint)
      end
    end

    factory :blueprint_with_unit, traits: [:with_unit]
    factory :blueprint_with_entity, traits: [:with_entity]
    factory :blueprint_with_spot, traits: [:with_spot]
  end

  factory :datum, class: Applyance::Datum do
    definition
    association :account, factory: :applicant_account
    detail "Detail..."
  end

  factory :coordinate, class: Applyance::Coordinate do
    lat 34.5
    lng -42.8
  end

  factory :application, class: Applyance::Application do
    association :submitter, factory: :applicant_account
    association :submitted_from, factory: :coordinate

    digest { SecureRandom.urlsafe_base64(nil, false) }
    submitted_at { DateTime.now }
    last_activity_at { DateTime.now }

    after(:create) do |application|
      application.add_spot(create(:spot))
      application.add_field(create(:field, :datum => create(:datum, :account => application.submitter)))
    end
  end

  factory :field, class: Applyance::Field do
    datum
    trait :with_application do
      application
    end
    factory :field_with_application, traits: [:with_application]
  end

  factory :pipeline, class: Applyance::Pipeline do
    association :unit, factory: :unit_with_reviewer
    sequence(:name) { |n| "Pipeline #{n}" }
  end

  factory :stage, class: Applyance::Stage do
    pipeline
    sequence(:name) { |n| "Stage #{n}" }
    sequence(:position) { |n| n }
  end

  factory :label, class: Applyance::Label do
    association :unit, factory: :unit_with_reviewer
    sequence(:name) { |n| "Label #{n}" }
    color "ff0000"
  end

  factory :segment, class: Applyance::Segment do
    reviewer
    sequence(:name) { |n| "Segment #{n}" }
    dsl "test"
  end

  factory :rating, class: Applyance::Rating do
    reviewer
    application
    spot
    sequence(:rating) { |n| n }
  end

end
