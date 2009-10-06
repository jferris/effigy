template = <<-XML
<?xml version="1.0"?>
<post>
  <title>a title</title>
  <user>
    <name>Joe</name>
    <email>joe@example.com</email>
  </user>
</post>
XML

view = Effigy::View.new

# set the contents of the /post/title element
view.css 'post title', 'new title'

# set the id attribute of the /post element
view.xpath '//post', :id => '5'

# set the contents and attributes of the /post/user/name element
view.xpath '//name', :contents => 'Bill', :full => 'false'

# Result document:
# <?xml version="1.0"?>
# <post id="5">
#   <title>new title</title>
#   <user>
#     <name full="false">Bill</name>
#     <email>joe@example.com</email>
#   </user>
# </post>
