require 'rails_helper'

RSpec.describe Achievement, type: :model do
  describe "validations" do
    it "requires title" do
      achievement = Achievement.new(title: '')
      # achievement.valid?
      # expect(achievement.errors[:title]).to include("can't be blank")
      # expect(achievement.errors[:title]).to_not be_empty
      expect(achievement.valid?).to be_falsy
    end

    it "requires title to be unique for one user" do
      user = FactoryGirl.create(:user)
      first_achievement = FactoryGirl.create(:achievement, title: 'First Achievement', user: user)
      # second_achievement = FactoryGirl.build(:achievement, title: 'First Achievement', user: user)
      second_achievement = Achievement.new(title: 'First Achievement', user: user)
      expect(second_achievement.valid?).to be_falsy
    end

    it "allows different users to have different titles" do
      user = FactoryGirl.create(:user)
      second_user = FactoryGirl.create(:user)
      first_achievement = FactoryGirl.create(:achievement, title: 'First Achievement', user: user)
      second_achievement = FactoryGirl.build(:achievement, title: 'First Achievement', user: second_user)
      expect(second_achievement.valid?).to be_truthy
    end

    it { should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("you can't have two achievements with the same title")}
    it { should validate_presence_of(:user) }
  end

  it "belongs to user" do
    achievement = Achievement.new(title: 'Some title', user: nil)
    expect(achievement.valid?).to be_falsy
  end

  it "has belongs_to user association" do
    # 1 approach
    user = FactoryGirl.create(:user)
    achievement = FactoryGirl.create(:public_achievement, user: user)
    expect(achievement.user).to eq(user)

    # 2 approach
    a = Achievement.reflect_on_association(:user)
    expect(a.macro).to eq(:belongs_to)
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:title)}

  it "converts  markdown to html" do
    achievement = Achievement.new(description: 'Awesome **thing** I *actually* did')
    expect(achievement.description_html).to eq("<p>Awesome <strong>thing</strong> I <em>actually</em> did</p>\n")
    expect(achievement.description_html).to include("<strong>thing</strong>")
    expect(achievement.description_html).to include("<em>actually</em>")
  end

  it "has silly title" do
    achievement = Achievement.new(title: "New title", user: FactoryGirl.create(:user, email: 'email@test.com'))
    expect(achievement.silly_title).to eq("New title by email@test.com")
  end

  it "searches for the title starting with a letter" do
    user = FactoryGirl.create(:user)
    achievement1 = FactoryGirl.create(:achievement, title: "Read a book", user: user)
    achievement2 = FactoryGirl.create(:achievement, title: "Swim a river", user: user)
    expect(Achievement.by_letter("R")).to eq([achievement1])
  end

  it "sorts achievements by created time" do
    user = FactoryGirl.create(:user)
    achievement1 = FactoryGirl.create(:achievement, title: "Read a book", user: user)
    achievement2 = FactoryGirl.create(:achievement, title: "Run!", user: user)
    expect(Achievement.by_letter("R")).to eq([achievement1, achievement2])
  end
end
