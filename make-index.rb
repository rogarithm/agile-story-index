require 'json'

raw = "2021년 03월\n2020년 05월"

partial_paths = []
raw.split("\n").each do |ym|
  partial_paths.push(
    ym.sub("년", "")
    .sub("월", "")
    .sub(" ", "/")
  )
end

response_jsons = []
partial_paths.each do |partial_path|
  response_json = `curl -X GET "https://archive.org/wayback/available?url=agile.egloos.com/archives/#{partial_path}"`
  url_to_visit = JSON.parse(response_json)["archived_snapshots"]["closest"]["url"]
  response_jsons.push(url_to_visit)
end

