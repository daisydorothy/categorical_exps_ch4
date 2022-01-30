import os, re, json

path = '/Users/daisy/Desktop/proj/eyeballs/experiments/norming/norm_ING_stims/'

audio_fnames_listodict = []
fname_pattern = '(\S+)(\.wav)'

for fname in os.listdir(path+'exp/static/audio/'):
    if fname.endswith('.wav'):
        fname_naked = re.sub('\.wav', '', fname)
        fnamedict = {}
        fnamedict['item'] = fname_naked
        audio_fnames_listodict.append(fnamedict)


print(audio_fnames_listodict)
#json.dump(audio_fnames_listodict, open(path+'/js/audio_fnames.js', 'w'))
