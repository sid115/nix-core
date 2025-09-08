import csv
import re
import sys

def process_csv(input_file, output_file):
    column_mapping = {
        'Group(/)': 'folder',
        'Title': 'name',
        'Password': 'login_password',
        'Notes': 'notes'
    }
    
    default_values = {
        'favorite': '',
        'type': 'login',
        'fields': '',
        'reprompt': '0',
        'login_uri': '',
        'login_username': '',
        'login_totp': ''
    }
    
    target_columns = [
        'folder', 'favorite', 'type', 'name', 'notes', 'fields', 
        'reprompt', 'login_uri', 'login_username', 'login_password', 'login_totp'
    ]
    
    with open(input_file, 'r', newline='', encoding='utf-8') as infile, \
         open(output_file, 'w', newline='', encoding='utf-8') as outfile:
        
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=target_columns)
        
        writer.writeheader()
        
        for row in reader:
            new_row = {}
            
            for old_col, new_col in column_mapping.items():
                new_row[new_col] = row.get(old_col, '')
            
            for col, default_val in default_values.items():
                if col not in new_row:
                    new_row[col] = default_val
            
            if new_row['notes']:
                new_row['notes'] = new_row['notes'].replace('\n', ' ').replace('\r', ' ')
                new_row['notes'] = re.sub(r'\s+', ' ', new_row['notes']).strip()
            
            notes = new_row['notes']
            if notes:
                # Look for pattern: "login: USERNAME"
                match = re.search(r'login:\s*(\S+)', notes, re.IGNORECASE)
                if match:
                    username = match.group(1)
                    new_row['login_username'] = username
                    new_row['notes'] = re.sub(r'login:\s*\S+', '', notes, flags=re.IGNORECASE).strip()
                    new_row['notes'] = re.sub(r'\s+', ' ', new_row['notes']).strip()
                    new_row['notes'] = new_row['notes'].strip(': ').strip()
            
            for key in new_row:
                if new_row[key]:
                    new_row[key] = str(new_row[key]).replace('\n', ' ').replace('\r', ' ')
                    new_row[key] = re.sub(r'\s+', ' ', new_row[key]).strip()
            
            writer.writerow(new_row)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file.csv> <output_file.csv>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    process_csv(input_file, output_file)
    print(f"Processing complete. Output saved to {output_file}")
