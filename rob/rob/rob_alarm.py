from rob_interface import *
import robos


def watch_rand_vid(r):
    'Function that gets called during wakeup'
    (playlist, vid_name) = get_random_playlist(r)
    first_item = playlist[0]
    show_name2 = os.path.split(first_item)[0].replace(r'D:\sys\e','').replace('E:','').replace('\\',' ').replace(':','').replace('TV','')
    print("vidname: %r " % (first_item,))
    robos.speak(r, 'How about some '+show_name2, -3)
    play_playlist(r, playlist)


def monitor(r, monitor_state='off'):
    robos.monitor(r, monitor_state)


def set_volume(r, percent):
    robos.set_volume(r, percent)


def get_random_playlist(r):
    import random
    random.seed()
    vid_files = []
    #TVDIRS = [r.d.TV, 'E:\\Documentaries']
    TVDIRS = [
        #r.d.TV + '\\Scrubs',
        #r.d.TV + '\\Bob Ross',
        r.d.TV + '\\Flight of the Conchords',
        r.d.TV + '\\Bill Nye The Science Guy',
        r.d.TV + '\\Monty Pythons Flying Circus'
    ]

    # Enforce existence
    TVDIRS2 = []
    from os.path import exists
    for tv_dir in TVDIRS:
        if exists(tv_dir):
            TVDIRS2 += [tv_dir]
    TVDIRS = TVDIRS2

    print(TVDIRS)
    print(r.d.TV)

    for tv_dir in TVDIRS:
        for vid_format in ['*.avi', '*.mkv', '*.wmv', '*.mp4']:
            vid_files.extend( [slash_fix(f) for f in  find_files(tv_dir, vid_format) ] )
    #vid_weights = [1./len(vid_files)]*len(vid_files)
    #random_pick(vid_files, vid_weights)
    pick1 = slash_fix(vid_files[random.randint(0,len(vid_files))])
    _show_name = pick1
    for tv_dir in TVDIRS:
        _show_name = _show_name.replace(slash_fix(tv_dir+'/'),'')
    show_name = _show_name[0:_show_name.find(slash_fix('/'))]
    playlist = [pick1]
    pick_index = vid_files.index(pick1)
    #vid_weights[pick_index] = 0
    #vid_weights = [vw/sum(vid_weights) for vw in vid_weights]
    num_vids = 5
    for i in range(0,min(len(vid_files),num_vids)):
        pick_N = slash_fix(vid_files[random.randint(0,len(vid_files)-1)])
        playlist.append(pick_N)
        pick_index = vid_files.index(pick_N)
        # vid_weights[pick_index] = 0
        # vid_weights = [vw/sum(vid_weights) for vw in vid_weights]
    print('---')
    print("PLAYLIST: \n  "+'\n  '.join(playlist))
    print('---')
    return (playlist, show_name)


def play_playlist(r, playlist=None):
    if playlist is None:
        (playlist, nm) = get_random_playlist(r)
    print('PLAYLIST: \n'+'\n'.join(playlist)+'\n\n')
    vlc_cmd = r.f.vlc_exe
    playlist = ['"' + vid + '"' for vid in playlist]
    arg_list = '"' + vlc_cmd + '" ' + ' '.join(playlist)
    #arg_list = [vlc_cmd] + playlist
    print(arg_list)

    subprocess.Popen(arg_list)

    #C:\Program Files (x86)\VideoLAN\VLC\vlc.exe "D:\sys\e\TV\Monty Pythons Flying Circus\Monty Pythons flying circus - Season 2\mpfc 14 - Face The Press.avi"


def get_night_videos(r):
    night_videos = [
        r.d.TV + '/Futurama',
        r.d.TV + '/Dr Horrible',
        r.d.TV + '/Mythbusters',
        r.d.TV + '/Adventure Time',
        r.d.TV + '/Dragonball Z',
    ]
    return night_videos


def get_morning_videos(r):
    morning_videos = [
        r.d.TV + '/Bill Nye the Science Guy',
    ]
    return morning_videos


def video(r):
    videos = (get_night_videos(r) +
              get_morning_videos(r))
    random_video(r, video_paths=videos)


def v(r):
    video(r)


def night_video(r):
    night_videos = get_night_videos(r)
    random_video(r, video_paths=night_videos)


def random_video(r, video_paths=None):
    from glob import glob
    import subprocess
    import numpy as np

    if video_paths == None:
        video_paths = [r.d.TV + '/Bill Nye the Science Guy']

    video_weights = np.ones(len(video_paths))
    video_weights /= len(video_paths)

    files   = []
    weights = []
    count = 0
    for path in video_paths:
        video_extensions = ['.avi','.mkv']
        video_files = []
        for ext in video_extensions:
            glob_str = slash_fix( path + '/*'+ext )
            video_files.extend(glob(glob_str))
        if video_files is not None:
            files.extend( video_files )
            new_weights = [video_weights[count]] * len(video_files)
            weights.extend(new_weights)
        count = count + 1

    randInt = random_pick(range(0, len(files)), weights) #random.randint(0,len(files));
    rand_vid_file =  files[randInt]

    vlc_cmd = r.f.vlc_exe
    arg_list = [vlc_cmd, rand_vid_file];
    subprocess.Popen(arg_list)


def get_readable_time(r):
    week_strs = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    month_strs = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    week_int = datetime.now().weekday()
    t = datetime.now()
    hour = str(((t.hour-1) % 12) +1)
    minu = '%.2d' % (t.minute)
    ampm = phonetic('A M')
    if t.hour >= 12:
        ampm = phonetic('P M')
    if minu[0] == '0':
        if minu[1] == '0':
            minu = phonetic('O ')+'clock, '
        else:
            minu = phonetic('O ')+minu[1]
    dplural = ''
    if t.day > 1:
        dplural = 's'
    month = month_strs[t.month - 1]
    day   = str(t.day)
    year  = str(t.year)
    weekday = week_strs[week_int]
    return (year, month, day, weekday, hour, minu, ampm)


def wake_up(r, WAKE_UP_MODE=0):
    if type(WAKE_UP_MODE) == type(''):
        WAKE_UP_MODE = int(WAKE_UP_MODE)
    (year, month, day, weekday, hour, minu, ampm) = get_readable_time(r)
    #if r.computer_name == "BakerStreet":
        #set_volume(r, 40)
    #else:
        #set_volume(r, 30)
    if WAKE_UP_MODE == 411:
        #set_volume(r, 50)
        webbrowser.open('http://www.youtube.com/watch?v=eh7lp9umG2I')
        return
    elif WAKE_UP_MODE == 0:
        wake_up_text = ''
    elif WAKE_UP_MODE == 2:
        wake_up_text = '''
        day na day na
        hey listen day na. Listen Listen!
        day na and jon
        I have something to tell you
        guess what
        did you guess yet
        ok, well here it is
        I have good news!
        You dont have to wake up.
        Isnt it wonderful?
        Do you love me yet day na?
        I just want to make you happy and this is the only way I know how
        '''
    elif WAKE_UP_MODE == 3:
        wake_up_text = '''
        ok
        this is going to suck a little bit
        but don't worry
        there is good news, and there is bad news.

        The bad news is it is around %s %s %s
        The date is %s %s, %s
        ... But here is the good news. it is %s, and %s is a fine day for science!
        ''' % ( hour, minu, ampm, month, day, year, weekday, weekday )
    elif WAKE_UP_MODE == 1:
        wake_up_text = '''
        wake up!
        wake up!
        wake up!
        This is your reminder to wake up!
        Wait
        I have a better idea
        '''

    rate_of_speach_base = -10
    text_lines = map(lambda x: x.strip(), wake_up_text.split('\n'))
    for i in range(len(text_lines)):
        line = text_lines[i]
        if line == "":
            continue
        import numpy as np
        percent_through = (float(i)/float(len(text_lines)))
        rate_of_speach = rate_of_speach_base + (8 * np.sqrt(percent_through))
        robos.speak(r, line, rate_of_speach)


    OLD_VID = False
    if OLD_VID:
        selectables = ['Bill Nye', 'Bob Ross', 'BBC Life', 'Sheep in the Big City']
        selection = 3
        show_name = selectables[selection]
        show_dir  = r.f.alarm_videos[show_name]
        robos.speak(r, 'How about some '+show_name2, -2)
        random_video(r, [show_dir])
    else:
        watch_rand_vid(r)


def WAKE_UP_MODE1(r):
        '''
        You are dreaming.
        You are dreaming.
        Jon and Day na please wake up.
        You are dreaming. You are dreaming. Jon and Day na please wake up.
        please wake up. please wake up. please wake up. Jon and Day na. pretty please wake up.
        This is not a dream. This is ROB. Im your robot friend.
        I realize this isnt very personal but you told me to wake you up, and Im trying.

        ok
        this is going to suck a little bit
        but dont worry

        There is good news, and there is bad news.'''


def sc(r, rate=-5):
    to_speak = robos.get_clipboard()
    robos.speak(r, to_speak, rate)


def speak(r, to_speak, rate=-5):
    print('alarm> Speaking at rate ' + str(rate) + ': ' + to_speak)
    robos.speak(r, to_speak, rate)


def s(r, num_cycles=5, monitoroff='False'):
    alarm_name = 'ROB_ALARM_TASK_0'
    num_cycles = int(num_cycles)
    from datetime import timedelta
    minutes_to_fall_asleep = 14
    if num_cycles == -1:
        num_cycles = 0
        minutes_to_fall_asleep = 1
    sleep_for = timedelta(hours=1.5 * num_cycles, minutes=minutes_to_fall_asleep)
    now_time = datetime.now()
    at = now_time + sleep_for
    time_str = '%.2d:%.2d' % (at.hour, at.minute)
    #date_str = '%.4d/%.2d/%.2d' % (at.year, at.month, at.day)  # this is correct
    date_str = '%.2d/%.2d/%.4d' % (at.month, at.day, at.year)  # this is default
    print("It takes %r minutes to fall asleep " % minutes_to_fall_asleep)
    print("ITS IS NOW:   " + str(now_time))
    print("ALARM SET FOR " + str(at))
    cmd  = 'schtasks /Create /SC ONCE /TN ' + alarm_name + ' /TR "rob.bat wake_up"  /ST ' + time_str + ' /SD ' + date_str + ' /F'
    os.system(cmd)
    if monitoroff != 'False':
        monitor(r, 'off')


def win32_chronjob(r, task_run, task_name, schedule='ONCE', modifier=None):
    supress_confirmation = True
    #task_run = "rob.bat wake_up"
    SCHEDULE_OPTS = ['MINUTE', 'HOURLY', 'DAILY', 'WEEKLY', 'MONTHLY', 'ONCE',
                     'ONSTART', 'ONLOGON', 'ONIDLE']
    cmd  = ['schtasks', '/Create',
            '/SC', schedule,
            '/TN', task_name,
            '/TR', task_run]
    if schedule in ['ONCE']:
        cmd += ['/ST', start_time]
        cmd += ['/SD', start_date]
    if modifier is not None:
        cmd += ['/MO', str(modifier)]
    if supress_confirmation is not None:
        cmd += ['/F']
    cmdstr = ' '.join(cmd)
    print(cmdstr)
    os.system(cmdstr)


def set_alarm(r, alarm_time=None, time_fix=True, alarm_name='ROB_ALARM_TASK_0'):
    import webbrowser
    from datetime import date, timedelta
    hour = '00'
    minu = '07'
    today = datetime.now()
    tomorrow = date.today() + timedelta(days=1)
    day = today.day
    month = today.month
    year = today.year
    if today.hour > 12 and time_fix is True:
        day = tomorrow.day
        month = tomorrow.month
        year = tomorrow.year
    date_str = '%.2d/%.2d/%.4d' % (month, day, year)
    print('TODAY IS: ' + str(today))
    print('TOMORROW IS: ' + str(tomorrow))
    print('ALARM IS SETTING FOR: ' + date_str)
    if alarm_time is None:
        webbrowser.open_new('http://sleepyti.me/')
        hour = '%.2d' % int(raw_input(   'Enter the alarm hours HH (00-23)'))
        minu = '%.2d' % int(raw_input('Enter the alarm minutres MM (00-59)'))
        alarm_time = hour + ':' + minu
    cmd  = 'schtasks /Create /SC ONCE /TN ' + alarm_name + ' /TR "rob.bat wake_up"  /ST ' + alarm_time + ' /SD ' + date_str + ' /F'
    print(cmd)
    os.system(cmd)
