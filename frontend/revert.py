import json

transcript_path = '/home/deepanshuk_k/.gemini/antigravity-ide/brain/a26efc0b-31bd-4b52-9918-ab25f6d40818/.system_generated/logs/transcript.jsonl'

files = {
    'app_theme.dart': None,
    'main.dart': None,
    'blog_list_screen.dart': None,
    'blog_card.dart': None,
    'login_screen.dart': None,
    'signup_screen.dart': None
}

with open(transcript_path, 'r') as f:
    for line in f:
        try:
            entry = json.loads(line)
            # Find TOOL_CALLS with write_to_file
            if entry.get('type') == 'TOOL_CALL':
                for tool_call in entry.get('tool_calls', []):
                    if tool_call.get('tool_name') == 'default_api:write_to_file':
                        args = tool_call.get('args', {})
                        target = args.get('TargetFile', '')
                        content = args.get('CodeContent', '')
                        for k in files.keys():
                            if k in target:
                                # Keep overwriting to get the latest. We will manually inspect if it's the one we want to revert to.
                                # To avoid getting the *bad* ones (which are the very last ones), we can store a list of contents.
                                if files[k] is None:
                                    files[k] = []
                                files[k].append(content)
        except Exception:
            pass

for k, v in files.items():
    print(f"{k}: {len(v) if v else 0} versions found")
    if v and len(v) > 1:
        # Write the second-to-last version (which is the one before our latest bad rewrite)
        with open(f"revert_{k}", "w") as f2:
            f2.write(v[-2])
        print(f"  -> Wrote revert_{k} (version -2)")
    elif v and len(v) == 1:
        with open(f"revert_{k}", "w") as f2:
            f2.write(v[-1])
        print(f"  -> Wrote revert_{k} (version -1)")

