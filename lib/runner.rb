require_relative 'index_maker'

class Runner
  def initialize
    @im = IndexMaker.new
  end

  def run
    #@im.make_partial_path_list "../data/posted_at_raw"
    #@im.make_url_list4index_page "../data/posted_at"
    @im.make_posts_info "../data/index_page_urls_first_15"
  end
end
