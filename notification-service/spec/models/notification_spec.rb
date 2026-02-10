require 'rails_helper'

RSpec.describe Notification, type: :model do
  it 'has a valid factory' do
    expect(build(:notification)).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of(:task_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:event_type) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:event_type).with_values(
        task_created: "task_created",
        task_completed: "task_completed",
        task_failed: "task_failed"
      ).backed_by_column_of_type(:string)
    end
  end
end