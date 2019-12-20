class PtkmsKnowledgeCommnet < ApplicationRecord
  has_many_attached  :attachments

  validates :name,length: { maximum: 255 }, presence: true
  validates :body, presence: true  
end
