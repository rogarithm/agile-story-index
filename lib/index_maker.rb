require 'json'
require 'nokogiri'
require_relative './post'

class IndexMaker
  posted_at = "2021년 03월\n2020년 05월\n2020년 02월\n2019년 09월\n2018년 12월\n2018년 04월\n2018년 03월\n2018년 02월\n2017년 07월\n2017년 05월\n2017년 04월\n2017년 03월\n2016년 12월\n2016년 11월\n2016년 08월\n2016년 07월\n2015년 12월\n2015년 11월\n2015년 09월\n2015년 08월\n2015년 06월\n2015년 05월\n2015년 04월\n2015년 03월\n2015년 02월\n2014년 12월\n2014년 11월\n2014년 09월\n2014년 08월\n2014년 03월\n2014년 01월\n2013년 12월\n2013년 10월\n2013년 08월\n2013년 06월\n2013년 05월\n2013년 04월\n2013년 02월\n2012년 09월\n2012년 08월\n2012년 06월\n2012년 05월\n2012년 03월\n2011년 12월\n2011년 11월\n2011년 10월\n2011년 09월\n2011년 04월\n2011년 03월\n2011년 02월\n2011년 01월\n2010년 12월\n2010년 10월\n2010년 09월\n2010년 08월\n2010년 07월\n2010년 06월\n2010년 05월\n2010년 04월\n2010년 03월\n2010년 02월\n2010년 01월\n2009년 12월\n2009년 11월\n2009년 10월\n2009년 09월\n2009년 08월\n2009년 07월\n2009년 06월\n2009년 05월\n2009년 04월\n2009년 03월\n2009년 02월\n2009년 01월\n2008년 12월\n2008년 11월\n2008년 10월\n2008년 09월\n2008년 08월\n2008년 07월\n2008년 06월\n2008년 05월\n2008년 04월\n2008년 03월\n2008년 02월\n2008년 01월\n2007년 12월\n2007년 11월\n2007년 10월\n2007년 09월\n2007년 08월\n2007년 07월\n2007년 06월\n2007년 05월\n2007년 04월\n2007년 03월\n2007년 02월\n2007년 01월\n2006년 12월\n2006년 11월\n2006년 10월\n2006년 09월\n2006년 08월\n2006년 07월\n2006년 06월\n2006년 05월\n2006년 04월\n2006년 03월\n2006년 02월"

  def make_partial_path_list posted_at
    partial_paths = []
    posted_at.split("\n").each do |ym|
      partial_paths.push(
        ym.sub("년", "")
        .sub("월", "")
        .sub(" ", "/")
      )
    end
    partial_paths
  end

  def make_url_list4index_page partial_paths
    index_page_urls = []
    partial_paths.each do |partial_path|
      response_per_month = `curl -X GET "https://archive.org/wayback/available?url=agile.egloos.com/archives/#{partial_path}"`
      index_url_per_month = JSON.parse(response_per_month)["archived_snapshots"]["closest"]["url"]
      index_page_urls.push(index_url_per_month)
    end
    index_page_urls
  end

  def make_posts_info index_page_urls
    posts_info = []
    index_page_urls.each do |index_page_url|
      index_page_per_month = `curl -X GET "#{index_page_url}"`
      doc = Nokogiri::HTML(index_page_per_month)
      doc.css(".POST_BODY > a").each do |post_info|
        title = post_info.content
        link = "http://web.archive.org" << post_info["href"]
        posts_info.push(Post.new(title, link))
      end
    end
    posts_info
  end

  def collect_index_content posts_info
    index_content = ""
    posts_info.each do |post_info|
      index_content << post_info.to_html
      index_content << "<br>\n"
    end
    index_content
  end

  def make_index_page index_content
    result = "
<html>
  <head>
    <meta charset=\"utf-8\">
  </head>
  <body>
    #{index_content}
  </body>
</html>
    "
    File.open('/tmp/agile-story-index.html', 'w') { |file| file.write(result) }
  end
end
