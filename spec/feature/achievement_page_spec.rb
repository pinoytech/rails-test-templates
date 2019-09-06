require 'rails_helper'
# require_relative '../support/login_form'

feature 'achievement page' do

  # let(:login_form) { LoginForm.new }
  let(:user) { FactoryGirl.create(:user) }
  let(:achievement) { FactoryGirl.create(:achievement, description: "That *was* hard", title: 'Just did it', user: user) }

  scenario 'achievement public page' do
    visit("/achievements/#{achievement.id}")
    expect(page).to have_content('Just did it')
    # achievements = FactoryGirl.create_list(:achievement, 3)
    # p achievements
  end

  scenario 'render markdown description' do
    visit("/achievements/#{achievement.id}")
    expect(page).to have_css('em', text: 'was')
  end
end