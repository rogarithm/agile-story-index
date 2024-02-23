class Post
  attr_reader :title, :link

  def initialize(title, link)
    @title = title
    @link = link
  end

  def to_html
    "<a href=\"#{@link}\">#{@title}</a>"
  end
end
