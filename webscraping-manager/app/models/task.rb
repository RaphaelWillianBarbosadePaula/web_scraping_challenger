class Task < ApplicationRecord
  enum :status, {
    pending: 'pending',
    processing: 'processing',
    concluded: 'concluded',
    failed: 'failed'
  }, default: :pending, validate: true

  validates :url, presence: true, length: { maximum: 2048 }, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "deve ser válida (http ou https)" }
  validates :title, presence: true, length: { maximum: 100 }
  validates :user_id, presence: true
  validates :status, presence: true
end
