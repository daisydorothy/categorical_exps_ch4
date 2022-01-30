from gtts import gTTS
import os.path
import json
import sys

audiopath = '/Users/daisy/Desktop/proj/eyeballs/experiments/norming/norm_ING_stims/exp/static/audio/test_audio/'

tts= gTTS(text='apple', lang='en-us', slow=False)
tts.save(audiopath+'audiotest.wav')
