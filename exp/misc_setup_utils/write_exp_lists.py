import os, re, json, copy, csv
from dataclasses import dataclass
import pprint as pp

path = '/Users/daisy/Desktop/proj/eyeballs/experiments/norming/norm_TOUGH_ING_stims/'

@dataclass
class StimCard:
    fname: str
    audiotype: str
    criticality: str
    explist: int = None
    lefttype: str = ''
    righttype: str = ''

def categorize_audios():
    fillers = []
    crits = []
    for fname in os.listdir(path+'exp/static/audio/'):
        if fname.endswith('.wav') and not fname.startswith('PRACTICE'):
            filler_id = re.sub('.wav', '', fname.split('_')[-1])
            if filler_id == 'F' or filler_id == 'M':
                stim = StimCard(fname, filler_id, 'FILLER')
                fillers.append(stim)
            else:
                # these are the tough marked and unmarked pairs
                if fname.split('_')[-2] == 'in':
                    stim = StimCard(fname, 'TM', 'CRITICAL')
                    crits.append(stim)
                if fname.split('_')[-2] == 'ing':
                    stim = StimCard(fname, 'TU', 'CRITICAL')
                    crits.append(stim)
    return fillers, crits

def assign_to_lists(listofstims, type1, type2):
    # Assign tough marked stims
    type1_list = [x for x in listofstims if x.audiotype == type1]
    type1_list = sorted(type1_list, key=lambda type1_list:type1_list.fname)
    for i in range(len(type1_list)):
        if i %2 == 0:
            type1_list[i].explist = 1
        else:
            type1_list[i].explist = 2
    #assign Tough unmarked stims
    type2_list = [x for x in listofstims if x.audiotype == type2]
    type2_list = sorted(type2_list, key=lambda type2_list:type2_list.fname)
    for i in range(len(type2_list)):
        if i %2 != 0:
            type2_list[i].explist = 1
        else:
            type2_list[i].explist = 2
    return type1_list + type2_list


def assign_img_positions(listofstims, type1, type2):
    explist1 = [x for x in listofstims if x.explist == 1]
    explist2 = [x for x in listofstims if x.explist == 2]
    for i in range(len(explist1)):
        if i % 2 == 0:
            explist1[i].lefttype = type1
            explist1[i].righttype = type2
        else:
            explist1[i].lefttype = type2
            explist1[i].righttype = type1
    for i in range(len(explist2)):
        if i % 2 == 0:
            explist2[i].lefttype = type1
            explist2[i].righttype = type2
        else:
            explist2[i].lefttype = type2
            explist2[i].righttype = type1
    return explist1 + explist2


def flip_lists(listofstims, type1, type2):
    list2 = copy.deepcopy(listofstims)
    for stim in list2:
        if stim.explist == 1:
            stim.explist = 3
        elif stim.explist == 2:
            stim.explist = 4
        if stim.lefttype == type1 and stim.righttype == type2:
            stim.lefttype = type2
            stim.righttype = type1
        elif stim.lefttype == type2 and stim.righttype == type1:
            stim.lefttype = type1
            stim.righttype = type2
    return listofstims + list2












fillers, crits = categorize_audios()

# First deal with Crits
listed_crits = assign_to_lists(crits, 'TM', 'TU')
imgassigned_crits = assign_img_positions(listed_crits, 'T', 'V')
all_crits_listed = flip_lists(imgassigned_crits, 'T', 'V')

# Now deal with the fillers
listed_fillers = assign_to_lists(fillers, 'F', 'M')
imgassigned_fillers = assign_img_positions(listed_fillers, 'F', 'M')
all_fillers_listed = flip_lists(imgassigned_fillers, 'F', 'M')




all_stims = all_crits_listed + all_fillers_listed
pp.pprint(all_stims)

# write to CSV
headers = ['audio', 'criticality', 'condition', 'exp_list', 'img_left_type', 'img_right_type']
with open(path+'exp/misc_setup_utils/exp_lists.csv', 'w')as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    for s in all_stims:
        row = [s.fname, s.criticality, s.audiotype, s.explist, s.lefttype, s.righttype]
        writer.writerow(row)

# dump to json
csvpath = path + 'exp/misc_setup_utils/exp_lists.csv'
jsonpath = path + 'exp/js/exp_files/exp_lists.json'

rows = []
with open (csvpath) as f:
    reader = csv.DictReader(f)
    with open (jsonpath, 'w') as fout:
        json.dump(list(reader), fout)
