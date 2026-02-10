FactoryBot.define do
  factory :notification do
    task_id { 1 }
    user_id { 1 }
    event_type { 'task_created' }
    data { { message: 'This is a test notification' } }
  end
end
