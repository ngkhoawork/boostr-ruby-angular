require 'rails_helper'

RSpec.describe EmailProcessor do
  let!(:email_activity) do
    create :activity_type, name: 'Email', company: company
  end

  it 'creates new activity from email' do
    expect {
      subject(html_email).process
    }.to change(Activity, :count).by 1
  end

  it 'saves html content into activity comment' do
    subject(html_email).process

    expect(Activity.last.comment).to include html_email[:html]
  end

  it 'recognizes users email capitalized' do
    email = build :email, :html_email, from: user.email.capitalize

    expect {
      subject(email).process
    }.to change(Activity, :count).by 1
  end

  context 'plain text email' do
    it 'processes email without html' do
      expect {
        subject(plain_text_email).process
      }.to change(Activity, :count).by 1
    end

    it 'gets raw email text into comment' do
      subject(plain_text_email).process

      expect(Activity.last.comment).to include html_email[:text]
    end
  end

  context 'blank email' do
    it 'saves empty string if email has no html and text' do
      expect {
        subject(blank_email).process
      }.to change(Activity, :count).by 1
    end

    it 'adds boilerplate as activity comment for blank emails' do
      subject(blank_email).process

      expect(Activity.last.comment).to eql '<div><strong>Email Subject - Boostr Email Activity</strong></div><div><strong>Email Body - </strong></div>'
    end
  end

  def subject(email)
    EmailProcessor.new(Griddler::Email.new(email))
  end

  def html_email
    @_html_email ||= build :email, :html_email, from: user.email
  end

  def plain_text_email
    @_plain_text_email ||= build :email, from: user.email
  end

  def blank_email
    @_blank_email ||= build :email, from: user.email, text: nil
  end

  def user
    @_user ||= create :user, company: company
  end

  def company
    @_company ||= create :company
  end
end
