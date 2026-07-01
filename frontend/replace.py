import os

files = [
    "lib/widgets/loading_indicator.dart",
    "lib/widgets/app_snackbar.dart",
    "lib/widgets/like_button.dart",
    "lib/screens/blogs/blog_detail_screen.dart",
    "lib/widgets/blog_card.dart"
]

for f in files:
    with open(f, 'r') as file:
        data = file.read()
    data = data.replace('AppColors.surfaceHigh', 'AppColors.surfaceWhite')
    with open(f, 'w') as file:
        file.write(data)
