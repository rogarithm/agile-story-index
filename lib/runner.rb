require_relative 'index_maker'

class Runner
  def initialize
    @im = IndexMaker.new
  end

  def get_full_path src
    File.expand_path(src, File.dirname(__FILE__))
  end

  def write_data data, to
    File.open(get_full_path(to), 'w+') do |file|
      data.each do |d|
        file << d
        file << "\n"
      end
    end
  end

  def run
    partial_paths = @im.make_partial_path_list File.read(get_full_path "../data/posted_at_raw")
    write_data(partial_paths, "../data/posted_at")

    index_page_urls = @im.make_url_list4index_page File.read(get_full_path "../data/posted_at")
    write_data(index_page_urls, "../data/index_page_urls")

    posts_info = @im.make_posts_info File.read(get_full_path "../data/index_page_urls_first_15")
  end
end
