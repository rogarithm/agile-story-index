require_relative '../lib/index_maker'

describe IndexMaker do
  it "gathers year_month info list from file" do
    im = IndexMaker.new
    partial_path_list = im.make_partial_path_list(
      File.expand_path("../data/posted_at_raw", File.dirname(__FILE__))
    )
    expect(partial_path_list.first).to eq('2021/03')
  end

  it "manipulates file content splitted by newline char" do
    im = IndexMaker.new
    index_page_urls = []
    partial_paths = File.read(File.expand_path("../data/posted_at", File.dirname(__FILE__)))
    expect(partial_paths.split("\n").first).to eq("2021/03")
  end
end
