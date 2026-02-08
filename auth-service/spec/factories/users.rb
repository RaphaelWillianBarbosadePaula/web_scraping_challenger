FactoryBot.define do
  factory :user do
    nickname { "UsuarioTeste" }
    email { Faker::Internet.unique.email }
    password { "senha123" }
    password_confirmation { "senha123" }
  end
end
