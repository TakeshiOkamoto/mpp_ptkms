class PtkmsProject < ApplicationRecord

  validates :name,length: { maximum: 255 }, presence: true, uniqueness: true
  validates :client_name, length: { maximum: 255 } 
  validates :show, inclusion: {in: [true, false]}
  
  # 日付の不正な値はSQLの例外をキャッチする
  # IE11以下は<input type="date">に対応していないので、動作が妙だがバグにはならない。

  # 検索対象のカラム ※デフォルトは全て
  def self.ransackable_attributes(auth_object = nil)
    %w[name show]
  end    
end
