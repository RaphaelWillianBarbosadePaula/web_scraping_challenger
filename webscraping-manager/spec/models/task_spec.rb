require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:url) }
    it { should validate_length_of(:url).is_at_most(2048) }
    it { should allow_value('http://example.com').for(:url) }
    it { should allow_value('https://example.com').for(:url) }
    it { should_not allow_value('ftp://example.com').for(:url) }
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 'pending', processing: 'processing', concluded: 'concluded', failed: 'failed').backed_by_column_of_type(:string) }
  end
end