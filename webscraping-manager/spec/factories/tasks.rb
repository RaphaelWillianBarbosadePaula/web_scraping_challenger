FactoryBot.define do
  factory :task do
    id { "1" }
    title { "Tarefa Teste" }
    url { "http://example.com" }
    status { "pending" }
    user_id { 1 }
    result_data { "" }
  end
end
