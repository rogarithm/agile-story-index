require 'json'
require 'nokogiri'
require_relative './post'

posted_at = "2021년 03월\n2020년 05월\n2012년 06월"

partial_paths = []
posted_at.split("\n").each do |ym|
  partial_paths.push(
    ym.sub("년", "")
    .sub("월", "")
    .sub(" ", "/")
  )
end

index_page_urls = []
partial_paths.each do |partial_path|
  response_per_month = `curl -X GET "https://archive.org/wayback/available?url=agile.egloos.com/archives/#{partial_path}"`
  index_url_per_month = JSON.parse(response_per_month)["archived_snapshots"]["closest"]["url"]
  index_page_urls.push(index_url_per_month)
end


posts_info = []
index_page_urls.each do |index_page_url|
  index_page_per_month = `curl -X GET "#{index_page_url}"`
  doc = Nokogiri::HTML(index_page_per_month)
  doc.css(".POST_BODY > a").each do |post_info|
    title = post_info.content
    link = post_info["href"]
    posts_info.push(Post.new(title, link))
  end
end

index_content = ""
posts_info.each do |post_info|
  index_content << post_info.to_html
  index_content << "<br>\n"
end

result = "<html>
	<head>
		<meta charset=\"utf-8\">
		<link rel=\"stylesheet\" href=\"./css/main.css\">
	</head>
	<body>
    #{index_content}
	</body>
</html>"
File.open('/tmp/agile-story-index.html', 'w') { |file| file.write(result) }
