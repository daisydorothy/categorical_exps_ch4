import os, csv, json

path = '/Users/daisy/Desktop/proj/eyeballs/experiments/eyetracking/online/DH_stims_online/exp/'


csvpath = path + 'misc_setup_utils/exp_lists.csv'
jsonpath = path + 'js/exp_files/exp_lists.json'

rows = []
with open (csvpath) as f:
    reader = csv.DictReader(f)
    with open (jsonpath, 'w') as fout:
        json.dump(list(reader), fout)
