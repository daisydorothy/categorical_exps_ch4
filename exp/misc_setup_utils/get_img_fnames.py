import os, re, json

path = '/Users/daisy/Desktop/proj/eyeballs/experiments/norming/norm_ING_stims/'
img_dict = {}
abbv = {'f': 'females', 'm': 'males', 't':'toughs', 'v': 'valleys'}
for fname in os.listdir(path+'/exp/static/imgs/'):
    if fname.endswith('.png') and not fname.startswith('PRACTICE'):
        cat = fname.split('_')[0]
        if abbv[cat] not in img_dict.keys():
            img_dict[abbv[cat]] = []
        img_dict[abbv[cat]].append(fname)
        # else:
        #     img_dict[abbv[cat]].append(fname)

json.dump(img_dict, open(path+'/exp/js/exp_files/img_fnames.js', 'w'))
