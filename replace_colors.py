import os
import re

lib_dir = '/home/iamkdraj/EdumyntOrg/edumyntorgapp/lib'

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # If AppColors is not used, skip
    if 'AppColors.primary' not in content and 'AppColors.secondary' not in content:
        return

    # Replace AppColors.primary -> Theme.of(context).colorScheme.primary
    # Replace AppColors.secondary -> Theme.of(context).colorScheme.secondary
    content = content.replace('AppColors.primary', 'Theme.of(context).colorScheme.primary')
    content = content.replace('AppColors.secondary', 'Theme.of(context).colorScheme.secondary')

    # Fix const errors by removing const from widgets that now use Theme.of(context)
    # This is a bit tricky, but we can do simple regex replacements for common cases:
    # const Text( -> Text(
    # const Icon( -> Icon(
    content = re.sub(r'const\s+(Text|Icon|TextStyle|BoxDecoration|BorderSide|EdgeInsets|Padding|SizedBox|Center)\(', r'\1(', content)
    content = content.replace('const [', '[') # Remove const from arrays just in case

    with open(filepath, 'w') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))

print("Done replacing.")
