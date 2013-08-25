Time.zone = "Tokyo"

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :rouge_syntax

activate :blog do |blog|
  blog.layout = "layout"
  blog.prefix = "post"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/:num"
end

page "/feed.xml", :layout => false
page "/articles.html", :layout => "articles"
page "/tags.html", :layout => "tags"
page "/year.html", :layout => "year"
page "/me.html", :layout => "me"

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
  activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  require "middleman-smusher"
  activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end
