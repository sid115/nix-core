if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pass_storepath> <output_csv>"
    exit 1
fi

pass2csv "$1" /tmp/pass.csv
python ./convert_csvs.py /tmp/pass.csv "$2"
rm /tmp/pass.csv
