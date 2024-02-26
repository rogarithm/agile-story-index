require 'json'
require 'nokogiri'
require_relative './post'

class IndexMaker
  attr_reader :partial_paths

  def make_partial_path_list src
    posted_at = src
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

  def make_url_list4index_page src
    partial_paths = src
    index_page_urls = []
    partial_paths.split("\n").each do |partial_path|
      response_per_month = `curl -X GET "https://archive.org/wayback/available?url=agile.egloos.com/archives/#{partial_path}"`
      index_url_per_month = JSON.parse(response_per_month)["archived_snapshots"]["closest"]["url"]
      index_page_urls.push(index_url_per_month)
    end
    index_page_urls
  end

  def take_in(data, range)
    ends_at = data.length - 1
    from = 0
    to = range - 1
    result = []
    loop do
      if from > ends_at
        break
      end
      result.push(data.slice(from..to))
      from += range
      to += range
    end
    result
  end

  def make_posts_info src
    index_page_urls = src
    posts_info = []
    index_page_urls.split("\n").each do |index_page_url|
      index_page_per_month = `curl -X GET "#{index_page_url}"`
      doc = Nokogiri::HTML(index_page_per_month)
      doc.css(".POST_BODY > a").each do |post_info|
        title = post_info.content
        link = "http://web.archive.org" << post_info["href"]
        posts_info.push(Post.new(title, link))
      end
    end
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
