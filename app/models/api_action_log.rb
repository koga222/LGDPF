# -*- coding:utf-8 -*-
class ApiActionLog < ActiveRecord::Base
  attr_accessible :unique_key, :entry_date

  before_create :set_attributes

  # before_createで設定する項目
  def set_attributes
    # 最初のレコードではApiActionLog.last.idが取得できないので、"0"を設定する
    self.unique_key = ApiActionLog.last.blank? ? "0" : (ApiActionLog.last.id + 1).to_s
    self.entry_date = Time.now
  end

end