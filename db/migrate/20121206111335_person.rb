# -*- coding:utf-8 -*-
class Person < ActiveRecord::Migration
  def self.up
    create_table :people, :force => true do |t|
      t.column "person_record_id", :string
      t.column "entry_date", :datetime
      t.column "expiry_date", :datetime
      t.column "author_name", :string
      t.column "author_email", :string
      t.column "author_phone", :string
      t.column "source_name", :string
      t.column "source_date", :datetime
      t.column "source_url", :string
      t.column "full_name", :string
      t.column "given_name", :string
      t.column "family_name", :string
      t.column "alternate_names", :string
      t.column "description", :text
      t.column "sex", :integer
      t.column "date_of_birth", :date
      t.column "age", :string
      t.column "house_number", :string
      t.column "home_street", :string
      t.column "home_neighborhood", :string
      t.column "home_city", :string
      t.column "home_state", :string
      t.column "home_postal_code", :string
      t.column "home_country", :string
      t.column "photo_url", :string
      t.column "profile_urls", :string
      t.column "public_flag", :integer

      t.column "in_city_flag", :integer
      t.column "shelter_name", :string
      t.column "refuge_status", :integer
      t.column "refuge_reason", :string
      t.column "shelter_entry_date", :date
      t.column "shelter_leave_date", :date
      t.column "next_place", :string
      t.column "next_place_phone", :string
      t.column "injury_flag", :integer
      t.column "injury_condition", :string
      t.column "allergy_flag", :integer
      t.column "allergy_cause", :string
      t.column "pregnancy", :integer
      t.column "baby", :integer
      t.column "upper_care_level_three", :integer
      t.column "elderly_alone", :integer
      t.column "elderly_couple", :integer
      t.column "bedridden_elderly", :integer
      t.column "elderly_dementia", :integer
      t.column "rehabilitation_certificate", :integer
      t.column "physical_disability_certificate", :integer
      t.column "link_flag", :boolean, :default => false
      t.column "notes_disabled", :boolean, :default => false
      t.column "email_flag", :boolean, :default => false
      t.column "deleted_at", :datetime
      t.timestamps
    end

    change_table :people do |t|
      t.set_column_comment "person_record_id", "GooglePersonFinderのperson_id"
      t.set_column_comment "entry_date", "レコード作成日時"
      t.set_column_comment "expiry_date", "レコード削除予定日時"
      t.set_column_comment "author_name", "レコード作成者名"
      t.set_column_comment "author_email", "レコード作成者のメールアドレス"
      t.set_column_comment "author_phone", "レコード作成者の電話番号"
      t.set_column_comment "source_name", "情報元のサイト名"
      t.set_column_comment "source_date", "情報元の投稿日"
      t.set_column_comment "source_url", "情報元のサイトURL"
      t.set_column_comment "full_name", "避難者名前"
      t.set_column_comment "given_name", "避難者_名"
      t.set_column_comment "family_name", "避難者_姓"
      t.set_column_comment "alternate_names", "避難者_よみがな"
      t.set_column_comment "description", "説明"
      t.set_column_comment "sex", "性別"
      t.set_column_comment "date_of_birth", "生年月日"
      t.set_column_comment "age", "年齢"
      t.set_column_comment "house_number", "番地"
      t.set_column_comment "home_street", "町名"
      t.set_column_comment "home_neighborhood", "近隣"
      t.set_column_comment "home_city", "市区町村"
      t.set_column_comment "home_state", "都道府県"
      t.set_column_comment "home_postal_code", "郵便番号"
      t.set_column_comment "home_country", "出身国"
      t.set_column_comment "photo_url", "写真のURL"
      t.set_column_comment "profile_urls", "プロフィールURL"
      t.set_column_comment "public_flag", '公開フラグ'

      t.set_column_comment "in_city_flag", "市内・市外区分"
      t.set_column_comment "shelter_name", "避難所"
      t.set_column_comment "refuge_status", "避難状況"
      t.set_column_comment "refuge_reason", "避難理由"
      t.set_column_comment "shelter_entry_date", "入所年月日"
      t.set_column_comment "shelter_leave_date", "退所年月日"
      t.set_column_comment "next_place", "退所先"
      t.set_column_comment "next_place_phone", "退所先電話番号"
      t.set_column_comment "injury_flag", "負傷"
      t.set_column_comment "injury_condition", "負傷内容"
      t.set_column_comment "allergy_flag", "アレルギー"
      t.set_column_comment "allergy_cause", "アレルギー物質"
      t.set_column_comment "pregnancy", "妊婦"
      t.set_column_comment "baby", "乳幼児"
      t.set_column_comment "upper_care_level_three", "要介護度３以上"
      t.set_column_comment "elderly_alone", "１人暮らしの高齢者"
      t.set_column_comment "elderly_couple", "高齢者世帯"
      t.set_column_comment "bedridden_elderly", "寝たきり高齢者"
      t.set_column_comment "elderly_dementia", "認知症高齢者"
      t.set_column_comment "rehabilitation_certificate", " 療育手帳所持者"
      t.set_column_comment "physical_disability_certificate", "身体障害者手帳所持者"
      t.set_column_comment "link_flag", "連携フラグ"
      t.set_column_comment "notes_disabled", "メモ無効フラグ"
      t.set_column_comment "email_flag", "新着メッセージ受取フラグ"
      t.set_column_comment "deleted_at", "削除日時"
      t.set_column_comment "created_at", "登録日時"
      t.set_column_comment "updated_at", "更新日時"
    end                    
  end                      
                           
  def down                 
  end                      
end                        