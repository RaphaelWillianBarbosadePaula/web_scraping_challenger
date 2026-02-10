class Notification < ApplicationRecord
  validates :task_id, presence: true
  validates :user_id, presence: true
  validates :event_type, presence: true

  enum :event_type, {
    task_created: "task_created",
    task_completed: "task_completed",
    task_failed: "task_failed"
  }
end
