import json

transcript_path = '/home/deepanshuk_k/.gemini/antigravity-ide/brain/a26efc0b-31bd-4b52-9918-ab25f6d40818/.system_generated/logs/transcript.jsonl'

versions = []

with open(transcript_path, 'r') as f:
    for line in f:
        try:
            entry = json.loads(line)
            tool_calls = entry.get('tool_calls', [])
            for tc in tool_calls:
                name = tc.get('name') or tc.get('tool_name')
                if name in ('default_api:write_to_file', 'write_to_file'):
                    args = tc.get('args', {})
                    if isinstance(args, str):
                        try:
                            args = json.loads(args)
                        except:
                            pass
                    if isinstance(args, dict):
                        target = args.get('TargetFile', '')
                        content = args.get('CodeContent', '')
                        if 'app_theme.dart' in target:
                            versions.append(content)
        except Exception:
            pass

for i, v in enumerate(versions):
    with open(f"app_theme_{i}.dart", "w") as f2:
        f2.write(v)
    print(f"Version {i}: {len(v)} bytes, {v.splitlines()[0] if v else ''}")
