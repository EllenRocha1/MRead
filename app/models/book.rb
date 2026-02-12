class Book < ApplicationRecord
  belongs_to :user

  validates :title, :author, :publish_year, presence: true
  validates :status, inclusion: { in: ["Para ler", "Lendo", "Lido"] }
  validates :isbn, uniqueness: { scope: :user_id }, allow_blank: true
end
