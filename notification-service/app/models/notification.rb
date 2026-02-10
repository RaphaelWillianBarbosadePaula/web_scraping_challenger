class Notification < ApplicationRecord
  validates :task_id, presence: true
  validates :user_id, presence: true
  validates :event_type, presence: true

  enum :event_type, {
    task_created: 0,
    task_completed: 1,
    task_failed: 2
  }
end
