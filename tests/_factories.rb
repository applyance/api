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
    name "reviewer"
  end

  factory :account, class: Applyance::Account do

    name "Stephen Watkins"
    sequence(:email) { |n| "account#{n}@gmail.com" }
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
    trait :reviewer do
      after(:create) { |account| account.add_role(Applyance::Role.first(:name => "reviewer")) }
    end

    factory :chief_account, traits: [:chief]
    factory :reviewer_account, traits: [:reviewer]
    factory :applicant_account, traits: [:applicant]

  end

  factory :entity, class: Applyance::Entity do
    name "The Iron Yard"
    domain

    after(:create) do |entity|
      entity.add_reviewer(create(:reviewer, :entity => entity))
      entity.add_reviewer_invite(create(:reviewer_invite, :entity => entity))
    end

    trait :with_definition do
      after(:create) do |entity|
        entity.add_definition(create(:definition))
      end
    end

    factory :entity_with_definition, traits: [:with_definition]
  end

  factory :applicant, class: Applyance::Applicant do
    association :account, factory: :applicant_account
  end

  factory :reviewer, class: Applyance::Reviewer do
    association :account, factory: :reviewer_account
    entity
    scope "admin"

    trait :limited do
      scope "limited"
    end

    factory :reviewer_limited, traits: [:limited]
  end

  factory :reviewer_invite, class: Applyance::ReviewerInvite do
    entity
    sequence(:email) { |n| "invite#{n}@gmail.com" }
    claim_digest { SecureRandom.urlsafe_base64(nil, false) }
    status "open"
    scope "admin"
  end

  factory :spot, class: Applyance::Spot do
    name "Spot 1"
    entity
    detail "Detail..."
    status "open"
  end

  factory :definition, class: Applyance::Definition do
    sequence(:label) { |n| "Definition #{n}" }
    description "Description..."
    is_sensitive false
    type "text"
  end

  factory :blueprint, class: Applyance::Blueprint do
    definition
    sequence(:position) { |n| n }
    is_required false

    trait :with_entity do
      after(:create) do |blueprint|
        create(:entity).add_blueprint(blueprint)
      end
    end

    trait :with_spot do
      after(:create) do |blueprint|
        create(:spot).add_blueprint(blueprint)
      end
    end

    factory :blueprint_with_entity, traits: [:with_entity]
    factory :blueprint_with_spot, traits: [:with_spot]
  end

  factory :datum, class: Applyance::Datum do
    definition
    applicant
    detail { { value: "Detail..." } }
  end

  factory :coordinate, class: Applyance::Coordinate do
    lat 34.5
    lng -42.8
  end

  factory :application, class: Applyance::Application do
    applicant

    digest { SecureRandom.urlsafe_base64(nil, false) }
    submitted_at { DateTime.now }
    last_activity_at { DateTime.now }

    after(:create) do |application|
      application.add_entity(create(:entity))
      application.add_field(create(:field, :datum => create(:datum, :applicant => application.applicant)))
    end

    trait :with_spot do
      after(:create) do |application|
        application.add_spot(create(:spot))
      end
    end

    factory :application_with_spot, traits: [:with_spot]
  end

  factory :field, class: Applyance::Field do
    datum
    trait :with_application do
      application
    end
    factory :field_with_application, traits: [:with_application]
  end

  factory :pipeline, class: Applyance::Pipeline do
    entity
    sequence(:name) { |n| "Pipeline #{n}" }
  end

  factory :stage, class: Applyance::Stage do
    pipeline
    sequence(:name) { |n| "Stage #{n}" }
    sequence(:position) { |n| n }
  end

  factory :label, class: Applyance::Label do
    entity
    sequence(:name) { |n| "Label #{n}" }
    color "ff0000"
  end

  factory :segment, class: Applyance::Segment do
    reviewer
    sequence(:name) { |n| "Segment #{n}" }
    dsl "test"
  end

  factory :rating, class: Applyance::Rating do
    account
    application
    sequence(:rating) { |n| n }
  end

  factory :note, class: Applyance::Note do
    reviewer
    application
    note "Detail..."
  end

end
