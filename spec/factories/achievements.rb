FactoryGirl.define do
  factory :achievement do
    sequence(:title) { |n| "Achievement #{n}" }
    description "A very long description"
    privacy :private_access
    featured false
    user
    cover_image "an image string"

    factory :public_achievement do
      privacy :public_access
    end

    factory :private_achievement do
      privacy :private_access
    end
  end
end
