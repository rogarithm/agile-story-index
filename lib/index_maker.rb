require 'json'
require 'nokogiri'
require_relative './post'

class IndexMaker
  API_RATE_LIMIT_PER = 1 * 120

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
    unable_to_get_urls = []
    every_15 = take_in(partial_paths.split("\n"), 15)
    every_15.each.with_index do |each_15, index|
      each_15.each do |partial_path|
        response_per_month = `curl -X GET "https://archive.org/wayback/available?url=agile.egloos.com/archives/#{partial_path}"`
        if JSON.parse(response_per_month)["archived_snapshots"] != {}
          index_url_per_month = JSON.parse(response_per_month)["archived_snapshots"]["closest"]["url"]
          index_page_urls.push(index_url_per_month)
        else
          retry_req = `curl -X GET "https://archive.org/wayback/available?url=agile.egloos.com/archives/#{partial_path}"`
          index_page_urls.push(JSON.parse(retry_req)["archived_snapshots"]["closest"]["url"]) if JSON.parse(retry_req)["archived_snapshots"] != {}
          unable_to_get_urls << partial_path
        end
      end
      sleep API_RATE_LIMIT_PER / 10 if index != every_15.length - 1
    end
    p unable_to_get_urls
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
    every_15 = take_in(index_page_urls.split("\n"), 15)
    every_15.each.with_index do |each_15, index|
      each_15.each do |index_page_url|
        index_page_per_month = `curl -X GET "#{index_page_url}"`
        doc = Nokogiri::HTML(index_page_per_month)
        doc.css(".POST_BODY > a").each do |post_info|
          title = post_info.content
          link = "http://web.archive.org" << post_info["href"]
          posts_info.push(Post.new(title, link))
        end
        sleep API_RATE_LIMIT_PER / 10 if index != every_15.length - 1
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
