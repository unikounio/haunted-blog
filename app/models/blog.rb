# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :viewable_by, ->(user) { published.or(where(user:)) }

  scope :search, ->(term) { where('title LIKE :term OR content LIKE :term', term: "%#{sanitize_sql_like(term.to_s)}%") }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end

  def self.sanitize_term(term)
    if term.present?
      sanitize_sql_like(term)
    else
      term
    end
  end
end
