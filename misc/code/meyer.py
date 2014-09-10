        #Type _a is the information gathering or perceiving (Intuition/Sensing) is dominant function in dominant mode
        #Type _b is the decision making  (Thinking/Feeling) is dominant function in dominant mode
        
        # Primary   is     lifestyle    alignment, usually with your dominant mode
        # Secondary is non-lifestyle    alignment, usually with your auxilary mode
        # Tertiary  is non-lifetyle non-alignment, with ??? mode
        # Shadow    is     lifetyle non-alignment, with ??? mode
        

types = {
    # Introverts
    # Type Bs - judgers / decision makers
    'ts-' : ([11,14],  [7,10], [14,19], 'ISTJ', '>sensing___THINKERS',   'Inspector,    Duty Fulfillers'),\
    'fs-' : ( [9,14], [15,20], [6,8],   'ISFJ', '>sensing___FEELERS ',    'Protector,    Nurturers'),\
    'fi-' : (  [1,3], [2,4],   [1,2],   'INFJ', '>intuition_FEELERS ',    'Counselor,    Protectors'),\
    'ti-' : (  [2,4], [1,3],   [2,6],   'INTJ', '>intuition_THINKERS',   'Mastermind,   Scientists'),\
    # Type As - perceivers / info gathers
    'st-' : (  [4,6], [2,3],   [6,9],   'ISTP', '>SENSING___thinkers',   'Crafter,      Mechanic'),\
    'sf-' : (  [5,9], [6,10],  [4,8],   'ISFP', '>SENSING___feelers ',    'Composer,     Artists'),\
    'if-' : (  [4,5], [4,7],  [3,5],    'INFP', '>INTUITION_feelers ',    'Healer,       Idealists'),\
    'it-' : (  [3,5], [1,3],   [4,7],   'INTP', '>INTUITION_thinkers',   'Architect,    Thinkers'),\
    # Extroverts
    # Type As - perceivers / info gathers
    'st+' : (  [4,5], [2,4],   [5,6],   'ESTP', '<SENSING___thinkers',   'Promoter,     Doers,       Dynamo'),\
    'sf+' : (  [4,9], [7,10],  [3,7],   'ESFP', '<SENSING___feelers ',    'Performer,    Performers'),\
    'if+' : (  [6,8], [8,10],  [5,7],   'ENFP', '<INTUITION_feelers ',    'Champion,     Inspirers'),\
    'it+' : (  [2,5], [2,4],   [3,7],   'ENTP', '<INTUITION_thinkers',   'Inventor,     Visionaries'),\
    # Type Bs - judgers / decision makers
    'ts+' : ( [8,12], [6,8],   [10,12], 'ESTJ', '<sensing___THINKERS',   'Supervisor,   Gaurdians'),\
    'fs+' : ( [9,13], [12,17], [5,8],   'ESFJ', '<sensing___FEELERS ',    'Provider,     Caregivers'),\
    'fi+' : (  [2,5], [3,6],   [1,3],   'ENFJ', '<intuition_FEELERS ',    'Champion,     Givers,      Teacher'),\
    'ti+' : (  [2,5], [1,4],   [3,6],   'ENTJ', '<intuition_THINKERS',   'Fieldmarshal, Executives,  Commander'),\
}




abrev = types.keys()
data = types.values()

populat = [tup[0] for tup in data]
populat_fem = [tup[1] for tup in data]
populat_men = [tup[2] for tup in data]
old_label = [tup[3] for tup in data]
new_label = [tup[4] for tup in data]
fun_label = [tup[5] for tup in data]

import numpy as np
ave = np.array([np.mean(x) for x in populat])
ave_f = np.array([np.mean(x) for x in populat_fem])
ave_m = np.array([np.mean(x) for x in populat_men])
ave_t = np.array([np.mean(x) for x in zip(ave_f, ave_m)])

def print_stat(ave, accur=100.0, trimfactor=1.0):
    popx = np.array(ave).argsort()
    tmp = ave.sum()
    tot = 0
    for x in popx:
        sel = ave[x] * 100.0 / float(tmp)
        #tot = accujj
        ##offset = 2
        #logtot = np.log2(tot+1)
        #logx = np.log2(sel+1)

        tot += sel
        perc = sel

        on = int(perc * (accur / 100.0) )
        off = int(100 * (accur / 100.0) / trimfactor )-on
        sep = '   '
        bar_disp = '[' + '='*on + ' '*off +']'
        ave_disp = '%4.1f%% ' %  perc
        label_disp = abrev[x] + sep + old_label[x] + sep + new_label[x]
        fun_disp = fun_label[x]

        print label_disp + sep + ave_disp + '  ' + bar_disp + ' ' + fun_disp
    print tot

print '\n\n  ' + ' '*75 + '___Women___'
print_stat(ave_f, 100.0)
print '\n\n  ' + ' '*75 + ' ___Men___'
print_stat(ave_m, 100.0)
print '\n\n  ' + ' '*75 + '___People___'
print_stat(ave_t, 100.0)


