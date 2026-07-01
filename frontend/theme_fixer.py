import os
import re

lib_dir = '/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/lib'

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # 1. Replace AppTextStyles.XXX with context.typography.XXX
    content = re.sub(r'AppTextStyles\.([a-zA-Z0-9_]+)', r'context.typography.\1', content)
    
    # 2. Remove const before context.colors or context.typography, or const Widgets that contain them.
    # This is trickier with regex. A safe approach is to remove "const " if it's on the same line as context.colors or context.typography
    lines = content.split('\n')
    for i in range(len(lines)):
        if 'context.colors' in lines[i] or 'context.typography' in lines[i]:
            # Simple heuristic: remove 'const ' from the line
            lines[i] = lines[i].replace('const ', '')
            lines[i] = lines[i].replace('const\n', '\n')
    
    content = '\n'.join(lines)
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'app_theme.dart':
            fix_file(os.path.join(root, file))

