import json

transcript_path = '/home/deepanshuk_k/.gemini/antigravity-ide/brain/a26efc0b-31bd-4b52-9918-ab25f6d40818/.system_generated/logs/transcript.jsonl'

files = {
    'app_theme.dart': [],
    'main.dart': [],
    'blog_list_screen.dart': [],
    'blog_card.dart': [],
    'login_screen.dart': [],
    'signup_screen.dart': []
}

with open(transcript_path, 'r') as f:
    for line in f:
        try:
            entry = json.loads(line)
            tool_calls = entry.get('tool_calls', [])
            for tc in tool_calls:
                name = tc.get('name') or tc.get('tool_name')
                if name in ('default_api:write_to_file', 'write_to_file'):
                    args = tc.get('args', {})
                    # sometimes args are nested or strings, let's handle if it's a dict
                    if isinstance(args, str):
                        try:
                            args = json.loads(args)
                        except:
                            pass
                    if isinstance(args, dict):
                        target = args.get('TargetFile', '')
                        content = args.get('CodeContent', '')
                        for k in files.keys():
                            if k in target:
                                files[k].append(content)
        except Exception as e:
            pass

for k, v in files.items():
    print(f"{k}: {len(v)} versions found")
    if v and len(v) > 1:
        # Write the second-to-last version
        with open(f"revert_{k}", "w") as f2:
            f2.write(v[-2])
        print(f"  -> Wrote revert_{k} (version -2)")
    elif v and len(v) == 1:
        with open(f"revert_{k}", "w") as f2:
            f2.write(v[-1])
        print(f"  -> Wrote revert_{k} (version -1)")

