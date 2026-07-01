import re

def fix_auth_pattern_painter(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Replace the class definition
    content = content.replace(
        "class _AuthPatternPainter extends CustomPainter {",
        "class _AuthPatternPainter extends CustomPainter {\n  final Color patternColor;\n  _AuthPatternPainter({required this.patternColor});"
    )
    # Replace context usage
    content = content.replace(
        "context.colors.accent.withValues",
        "patternColor.withValues"
    )
    # Update caller
    content = content.replace(
        "CustomPaint(painter: _AuthPatternPainter())",
        "CustomPaint(painter: _AuthPatternPainter(patternColor: context.colors.accent))"
    )
    
    with open(filepath, 'w') as f:
        f.write(content)

fix_auth_pattern_painter('/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/lib/screens/auth/login_screen.dart')
fix_auth_pattern_painter('/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/lib/screens/auth/signup_screen.dart')

def fix_blog_list_painters(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # AppPatternPainter
    content = content.replace(
        "class AppPatternPainter extends CustomPainter {",
        "class AppPatternPainter extends CustomPainter {\n  final Color color;\n  AppPatternPainter(this.color);"
    )
    content = content.replace("context.colors.ink.withValues", "color.withValues")
    
    # _DotPatternPainter doesn't use context.colors (it uses Colors.white) - oh wait, it was using Colors.white!
    # Update callers
    content = content.replace(
        "CustomPaint(painter: AppPatternPainter())",
        "CustomPaint(painter: AppPatternPainter(context.colors.ink))"
    )
    
    # _accentStrip method
    content = content.replace(
        "Widget _accentStrip() =>",
        "Widget _accentStrip(BuildContext context) =>"
    )
    content = content.replace(
        "child: _accentStrip(),",
        "child: _accentStrip(context),"
    )

    with open(filepath, 'w') as f:
        f.write(content)

fix_blog_list_painters('/home/deepanshuk_k/Documents/Deepanshu/Andriod/Blog_app/frontend/lib/screens/blogs/blog_list_screen.dart')

print("Fixed painters!")
