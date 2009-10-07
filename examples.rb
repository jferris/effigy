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
  </body>
</html>
HTML

post = Post.first

view = Effigy::View.new
view.render(template) do
  view.text('h1', post.title)
  view.text('title').text("#{post.title} - Site title")
  view.text('p.body').text(post.body)
  view.examples_for('.comment', post.comments) do |comment|
    view.text('h2', comment.title)
    view.text('p', comment.summary)
    view.attributes('a', :href => url_for(comment))
  end
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
