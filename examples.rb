template = <<-HTML
<html>
  <head>
    <title></title>
  </head>
  <body>
    <h1></h1>
    <p class="body"></p>
    <div class="comment">
      <h2></h2>
      <p></p>
      <a>View more</a>
    </div>
    <p id="no-comments">There aren't any comments for this post.</p>
  </body>
</html>
HTML

post = Post.first

view = Effigy::View.new
view.render(template) do
  view.text('h1', post.title)
  view.text('title', "#{post.title} - Site title")
  view.text('p.body', post.body)
  view.replace_with_each('.comment', post.comments) do |comment|
    view.text('h2', comment.title)
    view.text('p', comment.summary)
    view.attributes('a', :href => url_for(comment))
    view.add_class_names('h2', 'you') if comment.user == current_user
  end
  view.remove('#no-comments') if post.comments.empty?
end

document = view.render(template)

# Result document:
# <html>
#   <head>
#     <title>Post title - Site title</title>
#   </head>
#   <body>
#     <h1>Post title</h1>
#     <p class="body">Post body</p>
#     <div class="comment">
#       <h2>First comment title</h2>
#       <p>First comment body</p>
#       <a href="/comments/1">View more</a>
#     </div>
#     <div class="comment">
#       <h2>Second comment title</h2>
#       <p>Second comment body</p>
#       <a href="/comments/2">View more</a>
#     </div>
#   </body>
# </html>

class PostView < Effigy::View
  attr_reader :post

  def initialize(post)
    @post = post
  end

  def transform
    text('h1', post.title)
    text('title', "#{post.title} - Site title")
    text('p.body', post.body)
    replace_with_each('.comment', post.comments) do |comment|
      text('h2', comment.title)
      text('p', comment.summary)
      attributes('a', :href => url_for(comment))
    end
    remove('#no-comments') if post.comments.empty?
  end
end

view = PostView.new(post)
document = view.render(template)
