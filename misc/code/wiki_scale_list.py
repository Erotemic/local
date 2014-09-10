#!/usr/bin/python
# -*- coding: iso-8859-15 -*-
import os, sys
import numpy as np

scale_str = '''
The following is a list of [[musical scale]]s and [[musical mode|mode]]s. Degrees are relative to the major scale.

{| class="wikitable sortable" align="center" style="font-size:90%; float:center; margin: 0 0 1em 1em;"
|+ List of musical scales and modes
! Name || Image || Sound || Degrees || # of pitch classes || Lower tetrachord || Upper tetrachord || Usual or unusual key signature
|-
| [[17 equal temperament]] ||  || {{audio|1 step in 17-et on C.mid|Play}} ||  || 17 ||  ||  || 
|-
| [[Acoustic scale]] || [[Image:Lydian dominant C.png|thumb|Acoustic scale on C.]] || {{audio|Lydian dominant C.mid|Play}} || 1 2 3 {{music|#}}4 5 6 {{music|b}}7 || 7 || whole tone || Dorian || 
|-
| [[Adonai malakh mode]] || [[Image:Adonai malakh on C.png|thumb|Adonai malakh mode on C.]] || {{audio|Adonai malakh on C.mid|Play}} || 1 2 3 4 5 {{music|b}}6 {{music|b}}7 || 7 || Lydian || Phrygian || Unusual
|-
| [[Aeolian mode]] or [[natural minor scale]] || [[Image:Aeolian mode C.png|thumb|Aeolian on C.]] || {{audio|Aeolian mode C.mid|Play}} || 1 2 {{music|b}}3 4 5 {{music|b}}6 {{music|b}}7 || 7 || Dorian || Phrygian || Usual
|-
| [[Algerian scale]] || [[Image:Algerian scale.png|thumb|Algerian scale on C.]] || {{audio|Algerian scale.mid|Play}} || 1 2 {{music|b}}3  {{music|#}}4 5 {{music|b}}6 7 etc. || variable ||  ||  || 
|-
| [[Alpha scale]] ||  || {{audio|Alpha scale step on C.mid|Play}} ||  || 15.39 ||  ||  || 
|-
| [[Altered scale]] || [[Image:C altered scale flats.png|thumb|Altered scale on C.]] || {{audio|Altered scale on C.mid|Play}} || 1 {{music|b}}2 {{music|b}}3 {{music|b}}4 {{music|b}}5 {{music|b}}6 {{music|b}}7 || 7 ||  || whole tone || 
|-
| [[Augmented scale]] || [[Image:Augmented scale.png|thumb|Augmented scale on C.]] || {{audio|Augmented scale on C.mid|Play}} || 1 {{music|b}}3 3 5 {{music|#}}5 7 || 6 ||  ||  || 
|-
| Bebop dominant scale || [[Image:Bebop dominant scale on C.png|thumb|Bebop dominant scale on C.]] || {{audio|Bebop dominant scale on C.mid|Play}} || 1 2 3 4 5 6 {{music|b}}7 7 || 8 ||  ||  || 
|-
| [[Beta scale]] ||  || {{audio|Beta scale step on C.mid|Play}} ||  || 18.75 ||  ||  || 
|-
| [[Blues scale]] || [[Image:Blues scale common.png|thumb|Blues scale on C.]] || {{audio|Blues scale common.mid|Play}} || 1 {{music|b}}3 4 {{music|#}}4 5 {{music|b}}7 || 6 ||  ||  || 
|-
| [[BohlenPierce scale]] ||  || {{audio|Bohlen-Pierce scale just.mid|Play}} ||  ||  ||  ||  || 
|-
| [[Chromatic scale]] || [[Image:Chromatische toonladder.png|thumb|Chromatic scale on C.]] || {{audio|ChromaticScaleUpDown.ogg|Play}} || 1 {{music|#}}1 2 {{music|#}}2 3 4 {{music|#}}4 5 {{music|#}}5 6 {{music|#}}6 7<br/>7 {{music|b}}7 6 {{music|b}}6 5 {{music|b}}5 4 3 {{music|b}}3 2 {{music|b}}2 1 || 12 ||  ||  || 
|-
| [[Delta scale]] ||  || {{audio|Delta scale step on C.mid|Play}} ||  || 85.7 ||  ||  || 
|-
| [[Dorian mode]] || [[Image:Dorian mode C.png|thumb|Dorian on C.]] || {{audio|Dorian mode C.mid|Play}} || 1 2 {{music|b}}3 4 5 6 {{music|b}}7 || 7 || Dorian || Dorian || Usual
|-
| [[Double harmonic scale]] || [[Image:Double harmonic scale on C.png|thumb|Double harmonic scale on C.]] || {{audio|Double harmonic scale.mid|Play}} || 1 {{music|b}}2 3 4 5 {{music|b}}6 7 || 7 ||  || Mixolydian || Unusual
|-
| [[Enigmatic scale]] || [[Image:Enigmatic scale on C.png|thumb|Enigmatic scale on C.]] || {{audio|Enigmatic scale on C.mid|Play}} || 1 {{music|b}}2 3 {{music|#}}4 {{music|#}}5 {{music|#}}6 7 || 7 ||  ||  || Unusual
|-
| [[EulerFokker genus]] ||  || {{audio|Euler-Fokker genus on C.mid|Play}} ||  || 6 ||  ||  || 
|-
| [[Flamenco mode]] || [[Image:Flamenco mode on C.png|thumb|Flamenco mode on C.]] || {{audio|Flamenco mode on C.mid|Play}} || 1 {{music|b}}2 3 4 5 {{music|b}}6 7 || 7 || Phrygian || Phrygian || Unusual
|-
| [[Gamma scale]] ||  || {{audio|Gamma scale step on C.mid|Play}} ||  || 34.29 ||  ||  || 
|-
| [[Gypsy scale]] || [[Image:Gypsy Minor Scale.png|thumb|Gypsy scale on C.]] || {{audio|Gypsy minor scale.mid|Play}} || 1 2 {{music|b}}3 {{music|#}}4 5 {{music|b}}6 {{music|b}}7 || 7 ||  || Phrygian || Unusual
|-
| [[Half diminished scale]] || [[Image:Half diminished scale C.png|thumb|Half diminished scale on C.]] || {{audio|Half diminished scale C.mid|Play}} || 1 2 {{music|b}}3 4 {{music|b}}5 {{music|b}}6 {{music|b}}7 || 7 ||  || whole tone || 
|-
| [[Harmonic major scale]] || [[Image:Harmonic major scale C.png|thumb|Harmonic major scale on C.]] || {{audio|Harmonic major scale C.mid|Play}} || 1 2 3 4 5 {{music|b}}6 7 || 7 || Lydian || Mixolydian || 
|-
| [[Harmonic minor scale]] || [[Image:Harmonic minor on C.png|thumb|Harmonic minor scale on C.]] || {{audio|Harmonic minor on C.mid|Play}} || 1 2 {{music|b}}3 4 5 {{music|b}}6 ({{music|natural}})7 || 7 || Dorian || Mixolydian || 
|-
| [[Harmonic Scale]] || [[Image:Harmonic Scale chromatic on C.png|thumb|Harmonic scale chromatic on C.]] ||  ||  || 144 ||  ||  || 
|-
| [[Hexany]] ||  ||  ||  ||  ||  ||  || 
|-
| [[Hirajoshi scale]] || [[Image:Hirajoshi_scale_on_C_Burrows.png|thumb|Hirajoshi scale on C.]] || {{audio|Hirajoshi_scale_on_C_Burrows.mid|Play}} || 1 2 {{music|b}}3 5 {{music|b}}6 || 5 ||  ||  || 
|-
| [[Hungarian gypsy scale]] || [[Image:Hungarian gypsy scale C.png|thumb|Hungarian gypsy scale on C.]] || {{audio|Hungarian gypsy scale C.mid|Play}} || 1 2 {{music|b}}3 {{music|#}}4 5 {{music|b}}6 7 || 7 ||  || Mixolydian || Unusual
|-
| [[Hungarian minor scale]] || [[Image:Hungarian minor scale on C.png|thumb|Hungarian minor scale on C.]] || {{audio|Hungarian minor scale on C.mid|Play}} || 1 2 {{music|b}}3 {{music|#}}4 5 {{music|b}}6 7 || 7 ||  || Mixolydian || 
|-
| [[In scale]] || [[Image:Miyako-bushi scale.png|thumb|''Miyako-bushi'' scale on D, equivalent to ''in'' scale on D, with brackets on fourths.]]
 || {{audio|Miyako-bushi scale.mid|Play}} || 1 {{music|b}}2 4 5 {{music|b}}6 || 5 ||  ||  || 
|-
| [[Insen scale]] || [[Image:Insen scale on C.png|thumb|Insen scale on C.]] || {{audio|Insen scale on C.mid|Play}} || 1 {{music|b}}2 4 5 {{music|b}}7 || 5 ||  ||  || 
|-
| [[Ionian mode]] or [[major scale]] || [[Image:Ionian mode C.png|thumb|Ionian on C.]] || {{audio|Ionian mode C.mid|Play}} || 1 2 3 4 5 6 7 || 7 || Lydian || Lydian || Usual
|-
| [[Istrian scale]] || [[Image:Istrian mode on C.png|thumb|Istrian mode on C.]] || {{audio|Istrian mode on C.mid|Play}} || 1 {{music|b}}2 {{music|b}}3 {{music|b}}4 {{music|b}}5 5 || 6 ||  ||  || 
|-
| [[Iwato scale]] || [[Image:Iwato scale on C.png|thumb|Iwato scale on C.]] || {{audio|Iwato scale on C.mid|Play}} || 1 {{music|b}}2 4 {{music|b}}5 {{music|b}}7 || 5 ||  ||  || 
|-
| [[Locrian mode]] || [[Image:Locrian mode C.png|thumb|Locrian on C.]] || {{audio|Locrian mode C.mid|Play}} || 1 {{music|b}}2 {{music|b}}3 4 {{music|b}}5 {{music|b}}6 {{music|b}}7 || 7 || Phrygian || whole tone || Usual
|-
| [[Lydian augmented scale]] || [[Image:Lydian augmented scale on C.png|thumb|Lydian augmented scale on C.]] || {{audio|Lydian augmented scale on C.mid|Play}} || 1 2 3 {{music|#}}4 {{music|#}}5 6 7 || 7 || whole tone ||  || 
|-
| [[Lydian mode]] || [[Image:Lydian mode C.png|thumb|Lydian on C.]] || {{audio|Lydian mode C.mid|Play}} || 1 2 3 {{music|#}}4 5 6 7 || 7 || whole tone || Lydian || Usual
|-
| Major [[bebop scale]] || [[Image:Major bebop scale on C.png|thumb|Major bebop scale on C.]] || {{audio|Major bebop scale on C.mid|Play}} || 1 2 3 4 5 ({{music|#}}5/{{music|b}}6) 6 7 || 7(8) ||  ||  || 
|-
| [[Major Locrian scale]] || [[Image:Major locrian C.png|thumb|Major Locrian scale C.]] || {{audio|Major locrian C.mid|Play}} || 1 2 3 4 {{music|b}}5 {{music|b}}6 {{music|b}}7 || 7 || Lydian || whole tone || 
|-
| Major [[pentatonic scale]] || [[Image:C major pentatonic scale.svg|thumb|Major pentatonic scale on C.]] || {{audio|PentMajor.mid|Play}} || 1 2 3 5 6 || 5 ||  ||  || Usual
|-
| [[Melodic minor scale]] || [[Image:Melodic minor ascending on C.png|thumb|Melodic minor scale on C.]] || {{audio|Melodic minor ascending on C.mid|Play}} || 1 2 {{music|b}}3 4 5 {{music|natural}}6 {{music|natural}}7 8 {{music|b}}7 {{music|b}}6 5 4 {{music|b}}3 2 1 || 9 || Dorian ||  || 
|-
| [[Melodic minor scale]] (ascending) || [[Image:Melodic minor ascending on C.png|thumb|Melodic minor scale on C.]] || {{audio|Melodic minor ascending on C.png|Play}} || 1 2 {{music|b}}3 4 5 6 7 || 7 || Dorian ||  || 
|-
| [[Minor pentatonic scale]] || [[Image:A minor pentatonic scale.svg|thumb|Minor pentatonic scale on A.]] || {{audio|PentMinor.mid|Play}} || 1 {{music|b}}3 4 5 {{music|b}}7 || 5 ||  ||  || Usual
|-
| [[Mixolydian mode]] || [[Image:Mixolydian mode C.png|thumb|Mixolydian on C.]] || {{audio|Mixolydian mode C.mid|Play}} || 1 2 3 4 5 6 {{music|b}}7 || 7 || Lydian || Mixolydian || Usual
|-
| [[Neapolitan major scale]] || [[Image:Neapolitan major scale on C.png|thumb|Neapolitan major scale on C.]] || {{audio|Neapolitan major scale on C.mid|Play}} || 1 {{music|b}}2 {{music|b}}3 4 5 6 7 || 7 || Phrygian || Lydian || Unusual
|-
| [[Neapolitan minor scale]] || [[Image:Neapolitan minor scale on C.png|thumb|Neapolitan minor scale on C.]] || {{audio|Neapolitan minor scale on C.mid|Play}} || 1 {{music|b}}2 {{music|b}}3 4 5 {{music|b}}6 7 || 7 || Phrygian || Mixolydian || Unusual
|-
| [[Non-Pythagorean scale]] ||  || {{audio|Non-Pythagorean scale on C.mid|Play}} ||  ||  ||  ||  || 
|-
| [[Octatonic scale]] || [[Image:Octatonic scales on C.png|thumb|Octatonic scales on C.]] || {{audio|Octatonic scales on C.mid|Play}} || 1 2 {{music|b}}3 4 {{music|b}}5 {{music|b}}6 6 7<br/>1 {{music|b}}2 {{music|b}}3 3 {{music|#}}4 5 6 {{music|b}}7 || 8 ||  ||  || 
|-
| [[Pelog]] ||  || {{audio|Pelog.ogg|Play}} ||  ||  ||  ||  || 
|-
| [[Persian scale]] || [[Image:Persian scale on C.png|thumb|Persian scale on C.]] || {{audio|Persian scale on C.mid|Play}} || 1 {{music|b}}2 3 4 {{music|b}}5 {{music|b}}6 7 || 7 ||  ||  || 
|-
| [[Phrygian dominant scale]] || [[Image:C Phrygian dominant scale.svg|thumb|Phrygian dominant on C.]] || {{audio|Phrygian dominant scale on C.mid|Play}} || 1 {{music|b}}2 3 4 5 {{music|b}}6 {{music|b}}7 || 7 ||  || Phrygian || Unusual
|-
| [[Phrygian mode]] || [[Image:Phrygian mode C.png|thumb|Phrygian on C.]] || {{audio|Phrygian mode C.mid|Play}} || 1 {{music|b}}2 {{music|b}}3 4 5 {{music|b}}6 {{music|b}}7 || 7 || Phrygian || Phrygian || Usual
|-
| [[Prometheus scale]] || [[Image:Prometheus scale on C.png|thumb|Prometheus scale on C.]] || {{audio|Prometheus scale on C.mid|Play}} || 1 2 3 {{music|#}}4 6 {{music|b}}7 || 6 ||  ||  || 
|-
| [[Quarter tone scale]] || [[Image:Quarter tone scale on C.png|thumb|Quarter tone scale C.]] || {{audio|Quarter tone scale on C.mid|Play}} || 1 {{music|t}}1 {{music|#}}1 {{music|#t}}1 2 {{music|t}}2 {{music|#}}2 {{music|#t}}2 3 {{music|t}}3 4 {{music|t}}4 {{music|#}}4 {{music|#t}}4 5 {{music|t}}5 {{music|#}}5 {{music|#t}}5 6 {{music|t}}6 {{music|#}}6 {{music|#t}}6 7 {{music|t}}7<br/>{{music|d}}8 7 {{music|d}}7 {{music|b}}7 {{music|db}}7 6 {{music|d}}6 {{music|b}}6 {{music|db}}6 5 {{music|d}}5 {{music|b}}5 {{music|db}}5 4 {{music|d}}4 3 {{music|d}}3 {{music|b}}3 {{music|db}}3 2 {{music|d}}2 {{music|b}}2 {{music|db}}2 1 || 24 ||  ||  || 
|-
| [[Scale of harmonics]] || [[Image:Scale of harmonics on C.png|thumb|Scale of harmonics C.]] || {{audio|Scale of harmonics on C.mid|Play}} ||  ||  ||  ||  || 
|-
| [[Slendro]] || [[Image:Slendro vs whole tone scale on C.png|thumb|Slendro on C compared to a whole tone scale on C.]] || {{audio|Slendro vs whole tone scale on C.mid|Play}} or {{audio|Gamelan.mid|Play}} ||  || 5 ||  ||  || 
|-
| [[Tritone scale]] || [[File:Tritone scale on C (extra).png|thumb|Tritone scale on C.]] || {{audio|Tritone scale on C.mid|Play}} || 1 {{music|b}}2 3 {{music|b}}5 5 {{music|b}}7 || 7 ||  ||  || 
|-
| [[Ukrainian Dorian scale]] || [[Image:Ukrainian Dorian mode on C.png|thumb|Ukrainian Dorian mode on C.]] || {{audio|Ukrainian Dorian mode on C.mid|Play}} || 1 2 {{music|b}}3 {{music|#}}4 5 6 {{music|b}}7 || 7 ||  || Dorian || Unusual
|-
| [[Whole tone scale]] || [[Image:Whole tone scale on C.png|thumb|Whole tone scale on C.]] || {{audio|Whole tone scale on C.ogg|Play}} || 1 2 3 {{music|#}}4 {{music|#}}5 {{music|#}}6 || 6 ||  ||  || 
|-
| [[Yo scale]] || [[File:Min'yo scale.png|thumb|''Minyo'' scale on D, equivalent to ''yo'' scale on D, with brackets on fourths.]]
 || {{audio|Min'yo scale.mid|Play}} || 1 {{music|b}}3 4 5 7 || 5 ||  ||  || 
|}

==See also==
*[[Bebop scale]]
*[[Chord-scale system]]
*[[Heptatonic scale]]
*[[Jazz scale]]
*[[List of chord progressions]]
*[[List of chords]]
*[[List of musical intervals]]
*[[Arabian maqam]]
*[[Modes of limited transposition]]
*[[Symmetric scale]]
*[[Synthetic modes]]
*[[Tetrachord]]

{{Scales}}

[[Category:Music-related lists]]
[[Category:Musical scales| List]]
'''

import re
ionian = np.array([ 1, 3, 5, 6, 8,10,12])-1


wiki_mode_dict = {}
wiki_mode_names = []

for line in scale_str.split('\n'):
    columns = line.split('||')
    if len(columns) > 4: 
        scale_name = columns[0].replace('[[','').replace(']]','').replace('|','')
        relio = columns[3]
        relio = re.sub(r'<br/>.*','', relio)
        relio = relio.replace('{{music|#}}','#')
        relio = relio.replace('{{music|b}}','b')
        relio = relio.replace('{{music|natural}}','')
        relio = relio.replace('(','')
        relio = relio.replace('etc.','')
        relio = relio.replace(')','')
        relio = relio.replace('/',' ')
        relio = re.sub('  *',' ',relio)
        relio = relio.strip(' ')

        if len(relio.replace(' ','')) < 4: continue
        if relio.find('{{music|#t}}') > -1: continue
        if relio == 'Degrees': continue
        scale = []
        for scalex_str in relio.split(' '):
            scalex = int(scalex_str.replace('#','').replace('b',''))
            notex  = ionian[np.mod(scalex-1, len(ionian))]
            if 'b' in scalex_str:
                notex -= 1
            if '#' in scalex_str:
                notex += 1
            scale.append(notex)
        scale = set(scale)
        scale = list(scale)
        wiki_mode_names.append(scale_name)
        wiki_mode_dict[scale_name] = scale

def get_wiki_modes():
    return wiki_mode_dict
def get_wiki_mode_names():
    return wiki_mode_names
