import json

transcript_path = '/home/deepanshuk_k/.gemini/antigravity-ide/brain/a26efc0b-31bd-4b52-9918-ab25f6d40818/.system_generated/logs/transcript.jsonl'

files_to_recover = {
    'app_theme.dart': '',
    'theme_provider.dart': '',
    'main.dart': '',
    'login_screen.dart': '',
    'signup_screen.dart': '',
    'blog_card.dart': '',
}

with open(transcript_path, 'r') as f:
    for line in f:
        try:
            entry = json.loads(line)
            # Check tool call responses for view_file
            if entry.get('type') == 'TOOL_RESPONSE':
                for res in entry.get('tool_responses', []):
                    if res.get('tool_name') == 'default_api:view_file':
                        output = res.get('output', '')
                        for filename in files_to_recover.keys():
                            if f"File Path: `file:///home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/lib/" in output and filename in output:
                                # This is a view_file response for the file
                                # Let's see if it shows the entire file
                                if "The above content shows the entire, complete file contents of the requested file." in output:
                                    # Extract the code
                                    # It has line numbers like "1: import ..."
                                    lines = output.split('\n')
                                    code_lines = []
                                    for l in lines:
                                        if ': ' in l and l.split(':')[0].isdigit():
                                            code_lines.append(l.split(': ', 1)[1])
                                    files_to_recover[filename] = '\n'.join(code_lines)
                                elif "Showing lines" in output:
                                    # Partially shown, maybe we can piece it together, but let's see what we got first
                                    pass
        except Exception as e:
            pass

for k, v in files_to_recover.items():
    print(f"{k}: {len(v)} characters")
    if len(v) > 0:
        # We can write them directly or print success
        # Wait, I need to know where they belong
        pass

