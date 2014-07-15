def find_monthly_url
  require 'nokogiri'
  require 'open-uri'

  doc = Nokogiri::HTML(open(CSV_DOWNLOAD_PAGE_URL))
  link = doc.css("a").find do |_link|
    _link.text[/\ANPPES Data Dissemination \(.*\)\Z/]
  end

  link.attributes['href'].value
end

def find_taxonomy_url
  require 'nokogiri'
  require 'open-uri'
  require 'date'

  doc = Nokogiri::HTML(open(TAXONOMY_CSV_DOWNLOAD_PAGE_URL))
  link = doc.css("a").find do |_link|
    yr = Date.today.strftime("%y")
    _link.text[/\AVersion #{yr}\./]
  end

  link.attributes["href"].value
end
