import sqlite3
import warnings
import sys
import time
import shutil
import re

literal_print = lambda x: x.replace('\r','\\r').replace('\n','\\n').replace('\t','\\t').replace('\\', '\\\\')
data_tag_re = re.compile(r'\r\n  "[^"]*":')
bibtex_tag_re  = re.compile('\\\\t[a-zA-Z0-9]+\\\\t= ')
bibtex_tag_re2 = re.compile('  [a-zA-Z0-9]+=')

fdir = r'C:/Users/jon.crall/AppData/Local/Quantisle/Qiqqa/1C2DBB57-EA06-4793-B693-A53605D20703'
fname = fdir+'/Qiqqa.library'


readonly = True
fixjournal = False

for argv in sys.argv[1:]:
    if 'do_write' == argv:
        readonly=False
    elif 'readonly' == argv:
        readonly=True
    elif 'fixjournal' == argv:
        fixjournal = True
    else:
        print 'Unknown Arg: '+str(argv)

# LIST OF REGEXS to fix the journal names in my qiqqa database
journal2_regex_list = \
    {
        'Science' : [],

        'Nature' : [],

        # Computer Vision 
        'AIPR' : ['2009 IEEE Applied Imagery Pattern Recognition Workshop \\(AIPR 2009\\)'],

        'CVIU': ['Computer Vision and Image Understanding'],

        'ICPR':['20[0-9][0-9] *[0-9]th International Conference on Pattern Recognition'],

        'PAMI':['IEEE transactions on pattern analysis and machine intelligence',\
               'Pattern Analysis and Machine Intelligence, IEEE Transactions on',\
               'IEEE Transactions on Pattern Analysis and Machine Intelligence'], 

        'ECCV':['ECCV','Computer Vision ECCV 20[0-9][0-9]',
               'Computer Vision--ECCV 20[0-9][0-9]'],

        'CVPR':['20[0-9][0-9] IEEE[a-zA-Z ]* Conference on Computer Vision and Pattern Recognition',
                'Vision anComputer d Pattern Recognition \\(CVPR\\), 2012 IEEE Conference on',
                'Computer Vision and Pattern Recognition \\(',
                'CVPR 20[0-9][0-9]',
                'Computer Vision and',
                'Computer Vision and Pattern',
                'Computer Vision and Pattern Recognition, 2007. CVPR\'[0-9][0-9]. IEEE Conference on',
                'Computer Vision and Pattern Recognition \\(CVPR\\), 20[0-9][0-9] IEEE Conference on',
                'Computer Vision and Pattern Recognition, 20[0-9][0-9]. CVPR 20[0-9][0-9]. Proceedings of the 20[0-9][0-9] IEEE Computer Society Confety Conference on',
                'Computer Vision and Pattern Recognition, 2006 IEEE Computer Society Conference on'],
        
        'CVPR Workshops': ['20[0-9][0-9] Conference on Computer Vision and Pattern Recognition Workshop'],

        'Pattern Recognition' : [],

        'Principles of Database Systems' : [],

        'Neural Networks'  : ['IEEE Neural Networks', 'IEEE NN'],

        'Image Processing' : ['IEEE Image Processing', 'IEEE IP'],

        'IJCV':['International Journal of Computer Vision', 'International journal of computer vision'],

        'ICCV':['20[0-9][0-9] IEEE [0-9]*[st][th] International Conference on Computer Vision',
                '20[0-9][0-9] International Conference on Computer Vision',
                'Proceedings of the [a-zA-Z]* IEEE International Conference on Computer Vision',
                'Vision, 20[0-9][0-9]. ICCV 20[0-9][0-9]. IEEE [0-9]*[st][th]',
                '[^W]*ICCV[^W]*',
                'of the 5th International Conference on',
                'Computer Vision, 20[0-9][0-9] IEEE [0-9]*th International Conference on',
                'Computer Vision, 2005.',
                '20[0-9][0-9] [0-9]*th International Conference on Pattern Recognition',
                'Computer Vision, 20[0-9][0-9] IEEE'], 

        'ICCV Workshops':['20[0-9][0-9] IEEE [0-9]*[st][th] International Conference on Computer Vision Workshops, ICCV Workshops',
                         'Vision Workshops \\(ICCV'],

        'ACCV' : ['Asian Conference on Computer Vision'],

        # Other Conferences / Journals

        'Pattern Recognition Letters' : [],

        'WACV':[],

        'ACM SIGKD': ['Proceedings of the eighth ACM SIGKDD international conference on Knowledge discovery and data mining - KDD \'02'],

        'Multimedia Information Retreival - MIR' : ['Proceedings of the international conference on Multimedia information retrieval - MIR \'[0-9][0-9]'],

        'BMVC':['Procedings of the British Machine Vision Conference 20[0-9][0-9]'],

        'SigGraph':['ACM SIGGRAPH Computer Graphics'],

        'ACM Image and Video Retrieval' : ['Proceedings of the 6th ACM international conference on Image and video retrieval'],

        'ACM Multimedia Retrieval' : [],

        'Multimedia Tools and Applications' : [], 

        'MIT-CSAIL' : ['MIT Computer Science and Artificial Intelligence Laboratory'],

        'The Journal of Machine Learning Research' : ['MIT CSAIL Journal of Machine Learning Research'],

        'ACM Multimedia' : [],

        'Momentum' : ['STSC JOURNAL, MOMENTUM'],

        'Neural Computation' : ['Neural Computation'], 

        'CIVR':['Proceeding of the ACM International Conference on Image and Video Retrieval - CIVR \'[0-9][0-9]'], 

        'IEEE Signal Processing Magazine':['Signal Processing Magazine, IEEE'],

        'IEEE Multimedia': ['IEEE TRANSACTIONS ON MULTIMEDIA'],

        'NIPS' : ['Advances in Neural Information',
                  'Advances in Neural Information Processing Systems *[0-9]*',
                  'Advances in Neural'],

        'Toward category-level object recognition' : ['TCLOR'],
        
        'SCG' : ['Proceedings of the twentieth annual symposium on Computational geometry - SCG \'04'],

        'Journal of Mammalogy' : [],

        'Journal of Zoology':['JoZ'],

        'Journal of Frontier Biology': ['JFB'], 

        'Journal of Applied Ecology': ['JAE'],

        'Journal of Applied Statistics' : ['Journal of applied statistics'],

        'Journal of Visualized Experiments' : [],

        'Frontiers in Zoology' : ['Frontiers in zoology'],

        'International Journal of Public Health' : ['International journal of public health'], 

        'International Journal of Biometric and Bioinformatics' : [],

        'International Workshop on Image Analysis for Multimedia Interactive Services' : ['WIAMIS'],

        'NSDI' : ['Proceedings of the 1st conference on Symposium on Networked Systems Design and Implementation'],

        'VISAPP' : ['Conference on Computer Vision Theory and'],

        'arXiv preprint' : ['[Aa]rXiv preprint.*'],

        #
        'ICASSP' : ['IEEE International Conference on Acoustics, Speech and Signal Processing',
                    'IEEE Acoustics, Speech and Signal Processing'],

        'Computational learning theory' : [],

        'Image and Vision Computing' : ['Image and vision computing'], 

        'Endangered Species Research' : [],

        'Lecture Notes in Computer Science' : ['Lecture Notes in Computer'],

        'IEEE Foundations of Computer Science' : [],

        'IEEE Data Engineering' : [],

        'IEEE Medical Imaging' : [],

        'IEEE Applied Imagery Pattern Recognition Workshop' : [],

        'Journal of Proteomics' : ['Proteomics'],

        'Biology Letters' : [],

        'Energy Minimization Methods in Computer Vision and Pattern Recognition' : ['Energy Minimazation Methods'],

        'International Conference on Very Large Data Bases' : [],

        'ACM SIGMOD' : ['ACM Special Interest Group on Managment of Data'],

        'Image Science for Interventional Techniques' : ['ISIT', 'isit.u-clermont1.fr'],

        'U Aachen Computer Graphics Group' : ['graphics.rwth-aachen.de'],

        'Centre for Visual Information Technology' : ['CVIT'],

        'CalTech' : [],

        'Western European Workshop on Research in Cryptology' : ['the proceedings of WEWORC'],

        'Rhodes University' : ['cs.ru.ac.za'],

        'University of Maryland' : ['cs.umd.edu'],

        'International Conference on Systesm Signals and Image Processing' : ['IWSSIP'],

        'Conference on Semantics, Knowledge and Grids' : ['ICSKG'] ,

        'Engineering Applications of Artificial Intelligence' : [],

        'Real-Time Imaging' : [],

        'U Bristol' : [],

        'Alvey vision conference' : [],

        'Inverse Problems and Imaging' : [],

        'RFIA' : ['Congres de Reconnaissance des Formes et Intelligence Artificielle'],
        
        'Computer Analysis of Human Behavior' : [],

        'Institute for Human and Machine Cognition' : ['IHMC'],

        'SIAM Journal on Imaging Sciences' : ['SIIMS'], 

        'Workshop on Artificial Intelligence and Statistics' : [],

        'Reports of the International Whaling Commission' : ['Reports of the International Whaling']
        
        }

journal_ignore = ['TCLOR', 'VIIS', 'MIT', 'RFIA', 'IHMC', 'ACCV', 'IJBB',\
                  'IEEE NN','ESR','IEEE ICDE', 'CalTech', 'IEEE IP' ,'ICSKG',\
                  'ICVLDB', 'IWSSIP','IPPR', 'Pattern Recognition Letters', 'IWSSIP', 'CLT',\
                 'The Journal of Machine Learning Research', 'Endangered Species Research',\
                 'Frontiers in zoology','U Bristol', 'Reports of the International Whaling',\
                 'Engineering Applications of Artificial Intelligence','Alvey vision conference',\
                 'Computer Analysis of Human Behavior', 'Pattern Recognition','Journal of visualized experiments: JoVE']

journal_ignore = ['Mendeley Desktop', 'Approaches to Learner'] 

def fix_journal(journal_entry,DBGPRINT=False):
    if DBGPRINT:
        print '    __'
        print '    ENTRY: '+ journal_entry
    head_pos = journal_entry.find('{')
    tail_pos = journal_entry.rfind('}')
    bib_head = journal_entry[head_pos]
    bib_tail = journal_entry[tail_pos:]
    journal_simplefix = journal_entry[head_pos+1:tail_pos]
    simple_regex_subs = [('\\\\\\\\ldots',''), ('  *', ' '), ('  *$',''), ('^  *','')]
    for (tofind, torep) in simple_regex_subs:
        journal_simplefix = re.sub(tofind, torep, journal_simplefix)
    journal_fullfix = journal_simplefix
    if DBGPRINT: print '    SIMPLE FIX: \"'+ journal_fullfix+'\"'
    for journal_torep in journal2_regex_list.keys():
        regex_list = journal2_regex_list[journal_torep]
        for journal_tofind in regex_list:
            journal_fullfix = re.sub('^'+journal_tofind+'$', journal_torep, journal_fullfix, flags=re.IGNORECASE)
    if DBGPRINT: print '    FULL FIX: '+ bib_head+journal_fullfix+bib_tail
    journal_entry = bib_head+journal_fullfix+bib_tail
    if DBGPRINT: print '    +__'
    return journal_entry

def parse_bibtex(val, DBGPRINT=False, fingerprint=None):
    if DBGPRINT: print "\n---\nPARSING: "+val
    bibdata_str = val
    bib_tail = '\\n}",'
    bibtex_tags = []
    bibtex_tags += bibtex_tag_re.findall(bibdata_str)
    if bibtex_tags == []:
        bibtex_tags += bibtex_tag_re2.findall(bibdata_str)
        pass
    bibtex_tags += [bib_tail]
    bibtag = bibtex_tags[0]
    bibpos = bibdata_str.find(bibtag)
    bib_head = bibdata_str[0:bibpos] # "@article{tagname\\n,
    bibval = None; new_bib = ''; _bibdict = {}
    if DBGPRINT: print "HEAD: "+bib_head
    if DBGPRINT: print "TAIL: "+bib_tail
    # PARSE BIB_TAGS
    for next_bibtag in bibtex_tags[1:]:
        next_bibpos = bibdata_str.find(next_bibtag)
        bibtag_name = bibtag.replace('\\t','').replace('=','').replace(' ','')
        bibval = bibdata_str[bibpos+len(bibtag):next_bibpos]
        _bibdict[bibtag_name] = bibval # FOR DEBUGGING
        if bibtag_name in ['journal', 'booktitle']:
            if fixjournal:
                fixed_val = fix_journal(bibval,DBGPRINT)
                cannonical_journals_ = [journal for journal in (journal2_regex_list.keys()+journal_ignore)]
                cannonical_journals  = ['{%s}\\n,' % j for j in cannonical_journals_]
                cannonical_journals += ['{%s},\\n' % j for j in cannonical_journals_]
                cannonical_journals += ['{%s}\\r\\n,' % j for j in cannonical_journals_]
                cannonical_journals += ['{%s},\\r\\n' % j for j in cannonical_journals_]
                if not fixed_val in cannonical_journals:
                    print fingerprint
                    print 'Could not fix the bibtag: '+ bibtag_name+'='+fixed_val+''
                    if 'title' in _bibdict.keys():
                        print 'Title: '+str(_bibdict['title'])
                    else:
                        print bibdata_str
                    print '---'
                elif fixed_val != bibval:
                    #print 'Fixed Journal = \''+ bibval+'\' -> \''+fixed_val+'\''
                    pass
                bibval = fixed_val
        elif bibtag_name in ['abstract', 'doi', 'file', 'issn','keywords',\
                            'month', 'volume','pages','publisher','number',\
                                'url','year','isbn','pmid','address','eprint',\
                                'arxivid','archiveprefix', 'author', 'title',\
                            'language','school','organization','urldate']:
            pass
        elif bibtag_name in 'annote':
            pass # my annotations
        else: 
            print('\n\n__\nUnknown BIBTAG NAME: '+\
                    bibtag_name+'\n BIBTAG VAL: \n'+bibval+'\n_') 
            pass
        new_bib += bibtag+bibval
        bibtag = next_bibtag
        bibpos = next_bibpos
    new_val = bib_head+new_bib+bib_tail
    return new_val
    # /END PARSE BIB_TAGS
    #--- DEBUG THINGS
    #if 'booktitle' in _bibdict.keys():
    #    for key in _bibdict.keys():
    #        if not key in ['annote']: continue print str(key)+' : '+str(_bibdict[key])
    # Change Val
    #if val != new_val:
    #    print '\n\n_______________'
    #    print 'OLD VAL\n'+val
    #    print '---------'
    #    print 'NEW VAL\n'+new_val
fngrprnt2_newdata = {}
fngrprnt2_olddata = {}
numChanged = 0
try:
    con = sqlite3.connect(fname)
    fngrprnt2_newdata = {}
    fngrprnt2_olddata = {}
    data_count = 0
    curr = con.execute('SELECT * FROM LibraryItem WHERE extension=\'metadata\'')
    fetched_rows = curr.fetchall()
    for row in fetched_rows:
    # PARSE ROWS{
        (fingerprint, extension, md5, data_buffer, last_update) = row
        data_str = str(data_buffer)
        data_tags = data_tag_re.findall(data_str)
        pos = -1
        tag = None
        val = None
        data_head = '{'
        data_tail = '\r\n}'
        new_data = ''
        isChanged = False
        for next_tag in data_tags+[data_tail]:
        # PARSE DATA TAGS {
            next_pos = data_str.find(next_tag)
            if tag != None:
                tagname = re.sub('[^a-zA-Z0-9]','',tag)
                val = data_str[pos+len(tag):next_pos]
                if tagname == 'BibTex' and not (val.find('{') == -1 or val.find('}') == -1):
                    newval = parse_bibtex(val, fingerprint=fingerprint )
                    if data_str.find('TheMendeleySupportTeam2011a') >= 0 and False:
                        print '_____________\nFOUND MY DEBUGCASE\n'
                        newval = parse_bibtex(val, True)
                        print '---'
                        print data_str
                        print '---'
                        print val
                        print '---'
                        print newval
                        print '\nEND FOUND MY DEBUGCASE\n____________________'
                    if newval != val:
                        isChanged = True
                        val = newval
                    data_count += 1
                new_data += tag+val
            pos = next_pos
            tag = next_tag
        # END PARSE DATA TAGS }
        if isChanged:
            fngrprnt2_newdata[fingerprint] = data_head+new_data+data_tail
            fngrprnt2_olddata[fingerprint] = data_str
    #END PARSE ROWS}
    print str(len(fngrprnt2_newdata.keys()))+" citations will change"

except sqlite3.Error, e:
    print "Error %s:" % e.args[0]
    sys.exit(1)
finally:
    if con:
        con.close()

if not readonly:
    bakname = fname+str(time.time())+'.bak'
    shutil.copyfile(fname,bakname) #Create backup
    try:
        con = sqlite3.connect(fname)
        for fingerprint in fngrprnt2_olddata.keys():
            new_data = fngrprnt2_newdata[fingerprint]
            old_data = fngrprnt2_olddata[fingerprint]
            lendiff = len(old_data) - len(new_data)
            if new_data == old_data: continue
            print "UPDATING TO NEW DATA. LENDIFF="+str(lendiff)
            sqlupdate = 'UPDATE LibraryItem SET data=? WHERE extension=\'metadata\' AND fingerprint=\''+fingerprint+'\''
            #print sqlupdate
            con.execute(sqlupdate, [buffer(new_data)])
        con.commit()
    except Exception as e:
        print 'ERROR Writing to database: '+str(e)
    finally:
        con.close()

#test_sql = 'SELECT data from LibraryItem WHERE fingerprint=\''+fingerprint+'\' AND extension=\'metadata\''
#cur = con.execute(test_sql)
#fetched = cur.fetchall();
#(databuff,) = fetched[0]
#print "SQLite version: %s" % data    

#f = open(fname,'rb')
#fstr = f.read()
#f.close()

#import re

#regex_cvpr = 
#[
    #'20\\d\\d IEEE Conference on Computer Vision and Pattern Recognition'
#]

#ostr = ''
#instr = fstr
#prev_pos = 0

#bibtex_pos = instr.find('"BibTex": ')
