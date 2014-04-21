require 'mechanize'
require 'logger'

class StreckenWetter

  def initialize(*args)
    @log = Logger.new("|tee streckenwetter.log")
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @log.info "start #{__FILE__}"
    @website = "http://www.dwd.de"
  end

  def start
    agent = Mechanize.new
    agent.log = Logger.new "mechanize.log"
    start_seite = agent.get @website
    start_seite_deutsch = start_seite.link_with(:href => /switchLang=de&_pageLabel=dwdwww_start/).click
    spezielle_nutzer = start_seite_deutsch.link_with(:href => /pageLabel=dwdwww_spezielle_nutzer/).click
    schifffahrt = spezielle_nutzer.link_with(:href => /_pageLabel=_dwdwww_spezielle_nutzer_schiffffahrt/ ).click
    seewetter_aktuell = schifffahrt.link_with(:href => /_pageLabel=_dwdwww_spezielle_nutzer_schiffffahrt_seewetter/).click
    seewetter_mittelmeer = seewetter_aktuell.link_with(:href => /Seewetter__Mittelmeer__teaser/).click
    strecken_wetter = seewetter_mittelmeer.link_with(:href => /Seewetterbericht__24__strecke__node/).click
    strecken_wetter_doc = strecken_wetter.parser
    strecken_wetter_doc_anfang = strecken_wetter_doc.search('//div[@class="blockBodyFliesstext"]')

    strecken_wetter_date_part = strecken_wetter_doc_anfang.search('//table/caption').text

    timestr = strecken_wetter_date_part.scan(/[a-zA-Z]+,.*\d+\sUTC/).join
    date_part = strecken_wetter_date_part.scan(/.*,\s(\d+\.\d+\.\d+)\s/).join
    utc_hour_part = timestr.scan(/(\d+)\sUTC/).join
    date = Time.parse(date_part)
    date_str = date.strftime("%F")
    @log.info "parsed data contains data dated with: #{timestr} with utc hour: #{utc_hour_part} and date: #{date_str}"

    filename = "strecken_wetter_#{date_str}_#{utc_hour_part}_UTC.html"

    # files exists?
    if File.exists?(filename)
      @log.info "file #{filename} already exists!"
    else
      write_file(filename, strecken_wetter_doc_anfang.to_xml)
    end

  end

  def write_file(filename, content)
    file = File.write(filename, content)
    @log.info("wrote file #{filename}")
  end

end

strecken_wetter = StreckenWetter.new
strecken_wetter.start
