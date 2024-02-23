require 'json'

posted_at = "2021년 03월\n2020년 05월"

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

