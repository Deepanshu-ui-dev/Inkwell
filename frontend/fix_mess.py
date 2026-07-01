import re
with open('lib/screens/blogs/blog_list_screen.dart', 'r') as f:
    text = f.read()

text = text.replace('context.context.colors.inks.', 'context.colors.')
text = text.replace('..context.colors.ink =', '..color =')
text = text.replace('paint.context.colors.ink =', 'paint.color =')
text = text.replace('this.context.colors.ink', 'this.color')
text = text.replace('final Color context.colors.ink;', 'final Color color;')

with open('lib/screens/blogs/blog_list_screen.dart', 'w') as f:
    f.write(text)

