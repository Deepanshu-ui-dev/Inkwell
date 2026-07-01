import os
import re

lib_dir = '/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/lib'

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # Replace AppColors.XXX with context.colors.XXX
    content = re.sub(r'AppColors\.([a-zA-Z0-9_]+)', r'context.colors.\1', content)
    
    if content != original:
        # Check if context.colors requires the extension
        if 'import \'package:blog_app/utils/app_theme.dart\';' in content:
            # good, app_theme.dart will have the extension
            pass
        elif 'AppTextStyles' in content:
            pass # probably imported
            
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'app_theme.dart':
            process_file(os.path.join(root, file))

