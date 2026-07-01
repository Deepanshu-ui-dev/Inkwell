import os

files = [
    "lib/widgets/blog_card.dart",
    "lib/widgets/comment_tile.dart",
    "lib/widgets/tag_chip.dart"
]

for f in files:
    with open(f, 'r') as file:
        data = file.read()
    data = data.replace('AppColors.accentDim', 'AppColors.surface')
    with open(f, 'w') as file:
        file.write(data)
