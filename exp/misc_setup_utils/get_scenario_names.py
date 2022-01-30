import csv, re, json, os

path = '/Users/daisy/Desktop/proj/eyeballs/experiments/norming/norm_ING_stims/'

scenes = []
with open(path + 'exp/misc_setup_utils/ING_exp_alternate_scenario_descriptions.csv') as f:
    reader = csv.reader(f)
    for row in reader:
        scenes.append(row)

audios = []
for fname in os.listdir(path+'exp/static/audio/'):
    if fname.endswith('.wav'):
        fname.upper()
        audios.append(fname)

all_stims_scened = []
for s in scenes:
    for a in audios:
        if a.startswith('PRACTICE'):
             a_naked = (' ').join(a.split('_')[1:4]).lower()
        else:
            a_naked = (' ').join(a.split('_')[0:3]).lower()
        if s[0] == a_naked:
            stimdict = {}
            stimdict['audio'] = a
            stimdict['actual'] = s[2].upper()
            stimdict['alt'] = s[3].upper()
            all_stims_scened.append(stimdict)

json.dump(all_stims_scened, open(path+'/exp/js/exp_files/scene_names.js', 'w'))
