FactoryGirl.define do

  to_create { |i| i.save }

  factory :domain, class: Applyance::Domain do
    sequence(:name) { |n| "Domain #{n}" }
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
      after(:create) { |account| account.add_role(Applyance::Role.first(:name => "admin")) }
    end
    trait :reviewer do
      after(:create) { |account| account.add_role(Applyance::Role.first(:name => "reviewer")) }
    end

    factory :chief_account, traits: [:chief]
    factory :admin_account, traits: [:admin]

  end

end
