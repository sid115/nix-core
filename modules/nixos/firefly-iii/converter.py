import argparse
import csv
import codecs
import io
import os
import re
from datetime import datetime

def utf8_converter(input_path):
    """
    Reads a file and ensures it's UTF-8 encoded, handling common German/English encodings.
    Tries UTF-8 first, then windows-1252 (commonly used for Central European languages).
    """
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            f.read(1024)
        return input_path, 'utf-8'
    except UnicodeDecodeError:
        print(f"DEBUG: {input_path} not strictly UTF-8, attempting windows-1252...")
        try:
            temp_file_path = f"{input_path}.utf8_temp"
            with open(input_path, 'r', encoding='windows-1252') as infile:
                with open(temp_file_path, 'w', encoding='utf-8') as outfile:
                    outfile.write(infile.read())
            print(f"DEBUG: Converted {input_path} from windows-1252 to UTF-8 at {temp_file_path}")
            return temp_file_path, 'utf-8'
        except UnicodeDecodeError as e:
            print(f"ERROR: Could not decode {input_path} with UTF-8 or windows-1252. Error: {e}")
            print("Please ensure the input file is correctly encoded (e.g., UTF-8 or windows-1252).")
            exit(1)
    except Exception as e:
        print(f"ERROR: An unexpected error occurred during UTF-8 conversion: {e}")
        exit(1)

CATEGORY_RULES = [
    (r'rewe|lidl|netto|aldi|edeka|globus|kaufland', 'Groceries'),
    (r'tankstelle|aral|shell|esso|total', 'Fuel'),
    (r'deutsche bahn|s-bahn|bus|ticket-service', 'Transport'),
    (r'amazon|ebay|zalando|otto|mediamarkt|saturn', 'Shopping'),
    (r'miete|nebenkosten|hausverwaltung', 'Rent'),
    (r'strom|gas|wasser|heizung', 'Housing Utilities'),
    (r'netflix|spotify|disney\+|youtube premium', 'Streaming'),
    (r'apotheke|arzt|krankenhaus', 'Health'),
    (r'gehalt|lohn|einkommen', 'Income'),
    (r'versicherung|kfz vers|haftpflicht', 'Insurance'),
    (r'smartphone|telekom|vodafone|o2', 'Communication'),
    (r'steuer|finanzamt', 'Taxes'),
    (r'bar|abhebung', 'Cash'),
    (r'kaffee|restaurant|pizza|döner|burger', 'Food'),
]

COMPILED_CATEGORY_RULES = [
    (re.compile(pattern, re.IGNORECASE), category)
    for pattern, category in CATEGORY_RULES
]

def assign_category(description):
    """
    Assigns a category to a transaction description based on predefined rules.
    """
    for pattern, category in COMPILED_CATEGORY_RULES:
        if pattern.search(description):
            return category
    return "Miscellaneous"

def process_comdirect(input_reader, output_writer):
    """
    Processes Comdirect CSV data according to the specified rules.
    Assumes input_reader is a file-like object or iterator providing lines.
    """
    target_header_map = {
        "date": "Buchungstag",
        "description": "Buchungstext",
        "amount": "Umsatz in EUR",
    }
    
    for _ in range(4):
        try:
            next(input_reader)
        except StopIteration:
            print("ERROR: Comdirect CSV has fewer than 5 lines after skipping. Cannot process.")
            return

    header_line = next(input_reader).strip()
    
    header_reader = csv.reader(io.StringIO(header_line), delimiter=';')
    original_headers_raw = next(header_reader)
    original_headers = [h.strip() for h in original_headers_raw]

    output_col_indices_map = [] 
    
    date_orig_idx = -1
    amount_orig_idx = -1
    description_orig_idx = -1

    output_headers = []

    for target_col_name, original_col_to_find in target_header_map.items():
        try:
            current_orig_idx = original_headers.index(original_col_to_find)
            output_col_indices_map.append(current_orig_idx)
            output_headers.append(target_col_name)

            if target_col_name == "date":
                date_orig_idx = current_orig_idx
            elif target_col_name == "description":
                description_orig_idx = current_orig_idx
            elif target_col_name == "amount":
                amount_orig_idx = current_orig_idx
                
        except ValueError:
            print(f"WARNING: Expected column '{original_col_to_find}' not found in Comdirect CSV. Output might be incomplete.")

    output_headers.append("category")

    output_writer.writerow(output_headers)

    all_data_lines = []
    for line in input_reader:
        if line.strip():
            all_data_lines.append(line.strip())

    num_lines_to_keep = max(0, len(all_data_lines) - 7)
    data_lines_to_process = all_data_lines[:num_lines_to_keep]

    for line in data_lines_to_process:
        try:
            row_reader = csv.reader(io.StringIO(line), delimiter=';')
            original_row = next(row_reader)
            
            output_row = []
            current_description = ""

            for original_col_index_to_extract in output_col_indices_map:
                if original_col_index_to_extract < len(original_row):
                    cell_value = original_row[original_col_index_to_extract]

                    if original_col_index_to_extract == amount_orig_idx:
                        cell_value = cell_value.replace('.', '').replace(',', '.')

                    elif original_col_index_to_extract == date_orig_idx:
                        try:
                            date_obj = datetime.strptime(cell_value, '%d.%m.%Y')
                            cell_value = date_obj.strftime('%Y-%m-%d')
                        except ValueError:
                            print(f"WARNING: Date '{cell_value}' is not in 'dd.mm.yyyy' format. Leaving as is.")
                    
                    if original_col_index_to_extract == description_orig_idx:
                        current_description = cell_value
                        
                    output_row.append(cell_value)
                else:
                    output_row.append("") 
            
            assigned_category = assign_category(current_description)
            output_row.append(assigned_category)

            output_writer.writerow(output_row)
        except csv.Error as e:
            print(f"WARNING: Skipping malformed line '{line}' due to CSV error: {e}")
        except Exception as e:
            print(f"WARNING: Skipping line '{line}' due to unexpected error: {e}")


BANK_PROCESSORS = {
    "comdirect": process_comdirect,
}

def main():
    parser = argparse.ArgumentParser(
        description="Converts bank CSV transfer data into a uniform CSV format."
    )
    parser.add_argument(
        "bank_id",
        choices=BANK_PROCESSORS.keys(),
        help="The ID of the bank whose CSV is being processed (e.g., comdirect)."
    )
    parser.add_argument(
        "input_file",
        help="Path to the input CSV file from the bank."
    )
    parser.add_argument(
        "-o", "--output_file",
        default="output.csv",
        help="Path to the output uniform CSV file (default: output.csv)."
    )

    args = parser.parse_args()

    bank_id = args.bank_id
    input_file_path = args.input_file
    output_file_path = args.output_file

    if not os.path.exists(input_file_path):
        print(f"ERROR: Input file not found: {input_file_path}")
        exit(1)

    print(f"Processing bank: {bank_id}")
    print(f"Input file: {input_file_path}")
    print(f"Output file: {output_file_path}")

    temp_input_path, encoding_used = utf8_converter(input_file_path)
    print(f"Input file ensured to be {encoding_used} at: {temp_input_path}")

    try:
        with open(temp_input_path, 'r', encoding='utf-8', newline='') as infile:
            with open(output_file_path, 'w', encoding='utf-8', newline='') as outfile:
                output_csv_writer = csv.writer(outfile, delimiter=',')

                processor_function = BANK_PROCESSORS[bank_id]

                processor_function(infile, output_csv_writer)

        print(f"Successfully converted data for {bank_id} to {output_file_path}")

    except KeyError:
        print(f"ERROR: No processing function found for bank ID: {bank_id}")
        print("Please ensure the bank ID is correctly spelled and a processor function exists.")
        exit(1)
    except Exception as e:
        print(f"An unexpected error occurred during processing: {e}")
        exit(1)
    finally:
        if temp_input_path != input_file_path and os.path.exists(temp_input_path):
            try:
                os.remove(temp_input_path)
                print(f"Cleaned up temporary file: {temp_input_path}")
            except OSError as e:
                print(f"WARNING: Could not remove temporary file {temp_input_path}: {e}")

if __name__ == "__main__":
    main()
