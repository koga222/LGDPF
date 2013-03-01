# -*- coding:utf-8 -*-
# バッチの実行コマンド
# rails runner Batches::ExportGooglePersonFinder.execute
# ==== options
# 実行環境の指定 :: -e production
require 'net/http'
require 'net/https'
require "rexml/document"
Net::HTTP.version_1_2

class Batches::ExportGooglePersonFinder
  def self.execute
    # 2重起動防止
    if File.exist?("tmp/ExportGooglePersonFinder")
      puts I18n.t("errors.messages.dual_boot")
    else
      f = File.open("tmp/ExportGooglePersonFinder", "w")
      
      puts " #{Time.now.to_s} ===== START ===== "

      # APIキーの読み込み
      @settings = YAML.load_file("#{Rails.root}/config/settings.yml")
      export_record_size = Person.where(:public_flag => Person::PUBLIC_FLAG_ON).size

      # アップロード対象のレコードがなくなるまで
      while export_record_size > 0
        target_records = Person.find_for_export_gpf
        export_record_size = export_record_size - target_records.size
        # 書き込み専用でファイルを開く（新規作成）
        file_path = Rails.root + "tmp/lgdpf#{Time.now.utc.xmlschema.gsub(":","")}.xml"
        File.open(file_path, "w") do |output_file|
          output_file.write(create_pfif)    # ファイルにデータ書き込み
        end
        
        # GooglePersonFinderにexport
        puts `curl -X POST -H 'Content-type: application/xml' --data-binary @#{file_path} https://www.google.org/personfinder/#{@settings["gpf"]["repository"]}/api/write?key=#{@settings["gpf"]["api_key"]} `

       # File.delete(file_path)  # 送信済みXMLファイルの削除
      end
      
      puts " #{Time.now.to_s} =====  END  ===== "
      f.close
      File.delete("tmp/ExportGooglePersonFinder")  # lockファイルの削除
      Person.update_all(:export_flag => false)
    end
  end

  # GooglePersonFinderへアップロードするデータの作成処理
  # ==== Args
  # ==== Return
  # PFIF形式の文字列
  # ==== Raise
  def self.create_pfif
    doc =  REXML::Document.new
    doc << REXML::XMLDecl.new('1.0', 'UTF-8')
    doc.add_element("pfif:pfif").add_namespace("pfif", "http://zesty.ca/pfif/1.4")

    # export対象を抽出する
    people = Person.find_for_export_gpf
    people.each do |person|
      node_person = doc.root.add_element("pfif:person")
      node_person.add_element("pfif:person_record_id").add_text("#{@settings["gpf"]["domain"]}/person.#{person.id}")  # LGDPFはドメイン名に変えるかも
      node_person.add_element("pfif:entry_date").add_text("#{person.entry_date.utc.xmlschema}")
      node_person.add_element("pfif:expiry_date").add_text("#{person.expiry_date.utc.xmlschema}")
      node_person.add_element("pfif:author_name").add_text("#{person.author_name}")
      node_person.add_element("pfif:author_email").add_text("#{person.author_email}") if person.author_email.present?
      node_person.add_element("pfif:author_phone").add_text("#{person.author_phone}") if person.author_phone.present?
      node_person.add_element("pfif:source_name").add_text("#{person.source_name}") if person.source_name.present?
      node_person.add_element("pfif:source_date").add_text("#{person.source_date.utc.xmlschema}") if person.source_date.present?
      node_person.add_element("pfif:source_url").add_text("#{person.source_url}") if person.source_url.present?
      node_person.add_element("pfif:full_name").add_text("#{person.full_name}")
      node_person.add_element("pfif:given_name").add_text("#{person.given_name}")
      node_person.add_element("pfif:family_name").add_text("#{person.family_name}")
      node_person.add_element("pfif:alternate_names").add_text("#{person.alternate_names}")
      node_person.add_element("pfif:description").add_text("#{person.description}") if person.description.present?
      node_person.add_element("pfif:sex").add_text("#{sex_parse_for_gpf(person.sex)}")
      node_person.add_element("pfif:date_of_birth").add_text("#{date_parse_for_gpf(person.date_of_birth)}")
      node_person.add_element("pfif:age").add_text("#{person.age}") if person.age.present?
      node_person.add_element("pfif:home_street").add_text("#{person.home_street}") if person.home_street.present?
      node_person.add_element("pfif:home_neighborhood").add_text("#{person.home_neighborhood}") if person.home_neighborhood.present?
      node_person.add_element("pfif:home_city").add_text("#{person.home_city}") if person.home_city.present?
      node_person.add_element("pfif:home_state").add_text("#{person.home_state}") if person.home_state.present?
      node_person.add_element("pfif:home_postal_code").add_text("#{person.home_postal_code}") if person.home_postal_code.present?
      node_person.add_element("pfif:home_country").add_text("#{person.home_country}") if person.home_country.present?
      node_person.add_element("pfif:photo_url").add_text("#{@settings["lgdpf"][Rails.env]["site"]}#{person.photo_url}") if person.photo_url.present?
      node_person.add_element("pfif:profile_urls").add_text("#{person.profile_urls}") if person.profile_urls.present?

      notes = Note.find_all_by_person_record_id(person.id)
      notes.each do |note|
        node_note = node_person.add_element("pfif:note")
        node_note.add_element("pfif:note_record_id").add_text("#{@settings["gpf"]["domain"]}/note.#{note.id}")
        node_note.add_element("pfif:person_record_id").add_text("#{@settings["gpf"]["domain"]}/person.#{note.person_record_id}")
        node_note.add_element("pfif:linked_person_record_id").add_text("#{@settings["gpf"]["domain"]}/person.#{note.linked_person_record_id}") if note.linked_person_record_id.present?
        node_note.add_element("pfif:entry_date").add_text("#{note.entry_date.utc.xmlschema}")
        node_note.add_element("pfif:author_name").add_text("#{note.author_name}")
        node_note.add_element("pfif:author_email").add_text("#{note.author_email}") if note.author_email.present?
        node_note.add_element("pfif:author_phone").add_text("#{note.author_phone}") if note.author_phone.present?
        node_note.add_element("pfif:source_date").add_text("#{note.source_date.utc.xmlschema}") if note.source_date.present?
        node_note.add_element("pfif:author_made_contact").add_text("#{note.author_made_contact}") if note.author_made_contact.present?
        node_note.add_element("pfif:status").add_text("#{status_parse_for_gpf(note.status)}") if note.status.present?
        node_note.add_element("pfif:email_of_found_person").add_text("#{note.email_of_found_person}") if note.email_of_found_person.present?
        node_note.add_element("pfif:phone_of_found_person").add_text("#{note.phone_of_found_person}") if note.phone_of_found_person.present?
        node_note.add_element("pfif:last_known_location").add_text("#{note.last_known_location}") if note.last_known_location.present?
        node_note.add_element("pfif:text").add_text("#{note.text}")
        node_note.add_element("pfif:photo_url").add_text("#{@settings["lgdpf"][Rails.env]["site"]}#{note.photo_url}") if note.photo_url.present?
     
        # GooglePersonFinderに送ったnote_record_idを保持する
        note.note_record_id = "#{@settings["gpf"]["domain"]}/note.#{note.id}"
        note.save
      end

      # GooglePersonFinderに送ったperson_record_idを保持する
      person.person_record_id = "#{@settings["gpf"]["domain"]}/person.#{person.id}"
      person.export_flag = true
      person.save
    end
    return doc.to_s
  end

  # date型をGooglePersonFinderの形式に変換する
  # === Args
  # _date_ :: date
  # === Return
  # ”yyyy-mm-dd”文字列
  # === Raise
  def self.date_parse_for_gpf(date)
    date.blank? ? "" : date.strftime("%Y-%m-%d")
  end

  # 性別をGooglePersonFinderの形式に変換する
  # === Args
  # _sex_ :: Person.sex
  # === Return
  # "female" | "male" | "other"
  # === Raise
  def self.sex_parse_for_gpf(sex)
    case sex
    when "1" then
      "male"
    when "2" then
      "female"
    when "3" then
      "other"
    else
      nil
    end
  end

  # 状況をGooglePersonFinderの形式に変換する
  # === Args
  # _status_ :: Note.status
  # === Return
  # "information_sought" | "is_note_author" | "believed_alive" | "believed_missing" | "believed_dead"
  # === Raise
  def self.status_parse_for_gpf(status)
    case status.to_i
    when Note::STATUS_INFORMATION_SOUGHT  # 情報を探している
      "information_sought"
    when Note::STATUS_IS_NOTE_AUTHOR      # 私が本人である
      "is_note_author"
    when Note::STATUS_BELIEVED_ALIVE      # この人が生きているという情報を入手した
      "believed_alive"
    when Note::STATUS_BELIEVED_MISSING    # この人を行方不明と判断した理由がある
      "believed_missing"
    when Note::STATUS_BELIEVED_DEAD       # この人物が死亡したという情報を入手した
      "believed_dead"
    else
      nil                  # 指定無し
    end
  end


end
