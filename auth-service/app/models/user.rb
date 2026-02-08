class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :nickname, presence: true, uniqueness: true, length: { maximum: 20 }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 255 }

  validates :password, presence: true, length: { minimum: 8 }, allow_nil: true
end
