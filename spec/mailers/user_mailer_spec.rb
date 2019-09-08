require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  # not needed anymore apparently
  # include Rails.application.routes.url_helpers 
  let(:achievement_id) { 1 }
  let(:email) { UserMailer.achievement_created('author@email.com', 1).deliver_now }

  it 'sends achievement created email to author' do
    expect(email.to).to include('author@email.com')
  end

  it 'has correct subject' do
    expect(email.subject).to eq('Congratulations with your new achievement!')
  end

  it 'has achievement link in body message' do
    expect(email.body).to include(achievement_url(achievement_id))
  end
end
