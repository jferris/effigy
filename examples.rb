template = <<-HTML
<html>
  <head>
    <title></title>
  </head>
  <body>
    <h1></h1>
    <p class="body"></p>
  </body>
</html>
HTML

post = Post.first

view = Effigy::View.new
view.render(template) do
  view.text('h1', post.title)
  view.text('title').text("#{post.title} - Site title")
  view.text('p.body').text(post.body)
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
#   </body>
# </html>
