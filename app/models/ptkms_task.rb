class PtkmsTask < ApplicationRecord

  validates :project_id, presence: true
  validates :title,length: { maximum: 255 }, presence: true # uniqueness: trueは各自で調整
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 } # 1以上5以下
  validates :show, inclusion: {in: [true, false]}
  
  # 検索対象のカラム ※デフォルトは全て
  def self.ransackable_attributes(auth_object = nil)
    %w[title show]
  end       
end
