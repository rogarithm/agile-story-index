require_relative '../lib/index_maker'

describe IndexMaker do
  it "gathers year_month info list from file" do
    im = IndexMaker.new
    partial_path_list = im.make_partial_path_list(
      File.read(File.expand_path("../data/posted_at_raw", File.dirname(__FILE__))))
    partial_path_list.each do |partial_path|
      expect(partial_path).to match(/[0-9]{4}\/[0-9]{2}/)
    end
  end

  it "manipulates file content splitted by newline char" do
    im = IndexMaker.new
    index_page_urls = []
    partial_paths = File.read(File.expand_path("../data/posted_at", File.dirname(__FILE__)))
    expect(partial_paths.split("\n").first).to eq("2021/03")
  end

  it "takes every x elements from input" do
    im = IndexMaker.new
    expect(im.take_in([1,2,3,4,5,6], 2)).to eq([[1,2], [3,4], [5,6]])
  end

  it "takes rest elements if remaining elements are smaller than x" do
    im = IndexMaker.new
    expect(im.take_in([1,2,3,4,5,6,7], 2)).to eq([[1,2], [3,4], [5,6], [7]])
  end

end
