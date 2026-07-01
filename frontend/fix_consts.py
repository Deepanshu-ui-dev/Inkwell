import re
import subprocess

def fix_errors():
    # Run flutter analyze
    result = subprocess.run(
        ['flutter', 'analyze'], 
        cwd='/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend',
        capture_output=True, text=True
    )
    
    # Parse lines
    errors = result.stdout.split('\n') + result.stderr.split('\n')
    
    for line in errors:
        if 'invalid_constant' in line or 'non_constant_list_element' in line:
            # Format: error • Invalid constant value • lib/screens/auth/login_screen.dart:72:36 • invalid_constant
            match = re.search(r'(lib/[a-zA-Z0-9_./]+):(\d+):\d+', line)
            if match:
                filepath = '/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/' + match.group(1)
                linenum = int(match.group(2))
                
                with open(filepath, 'r') as f:
                    lines = f.readlines()
                
                # Remove 'const ' from the specific line
                idx = linenum - 1
                if idx < len(lines) and 'const ' in lines[idx]:
                    lines[idx] = lines[idx].replace('const ', '')
                    
                    with open(filepath, 'w') as f:
                        f.writelines(lines)
                        print(f"Fixed const on {filepath}:{linenum}")

if __name__ == "__main__":
    # Run multiple passes to catch cascaded errors
    for i in range(3):
        print(f"Pass {i+1}")
        fix_errors()
        
