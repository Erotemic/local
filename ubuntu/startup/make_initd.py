import ubelt as ub
# _self_install(){
#     "
#     Referenes:
#         https://poundcomment.wordpress.com/2009/08/28/ubuntu-cpu-temperature-terminal-prompt/
#         http://www.tldp.org/HOWTO/HighQuality-Apps-HOWTO/boot.html
#     "
# }
from os.path import basename, splitext, expanduser, join


INITD_TEMPLATE = ub.codeblock(
    '''
    #!/bin/sh
    ### BEGIN INIT INFO
    # Provides:          {name}
    # Required-Start:    $local_fs $network
    # Required-Stop:     $local_fs
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: custom script
    # Description:       custom script
    ### END INIT INFO


    PIDFILE="/var/run/{name}.pid"
    NAME="{name}"
    DAEMON="{fpath}"

    # Return 0, process already started.
    # Return 1, start cpu_temp
    do_start()
    {{
            if [ -f $PIDFILE ]; then
                    return 0
            fi
            $DAEMON &
            echo "$!" > $PIDFILE
            return 1
    }}

    # Return 0, process not started.
    # Return 1, kill process
    do_stop()
    {{
            if [ ! -f $PIDFILE ]; then
                    return 0
            fi
            kill -9 `cat $PIDFILE`
            rm $PIDFILE
            return 1
    }}

    case "$1" in
      start)
            do_start
            case "$?" in
                    0) echo "$NAME already started." ;;
                    1) echo "Started $NAME." ;;
            esac
            ;;
      stop)
            do_stop
            case "$?" in
                    0) echo "$NAME has not started." ;;
                    1) echo "Killed $NAME." ;;
            esac
            ;;

      status)
            if [ ! -r "$PIDFILE" ]; then
                    echo "$NAME is not running."
                    exit 3
            fi
            if read pid < "$PIDFILE" && ps -p "$pid" > /dev/null 2>&1; then
                    echo "$NAME is running."
                    exit 0
            else
                    echo "$NAME is not running but $PIDFILE exists."
                    exit 1
            fi
            ;;
      *)
            N=/etc/init.d/$NAME
            echo "Usage: $N {{start|stop|status}}" >&2
            exit 1
            ;;
    esac

    exit 0
    ''')


def make_initd(fpath):
    name = splitext(basename(fpath))[0]
    text = INITD_TEMPLATE.format(name=name, fpath=fpath)
    startup_hook = expanduser(join('~/local/ubuntu/startup/init.d', name))
    ub.writeto(startup_hook, text)
    print(ub.codeblock(
        '''
        RUN:
        sudo cp {startup_hook} /etc/init.d/{name}
        sudo chmod +x /etc/init.d/{name}
        # sudo update-rc.d /etc/init.d/{name} defaults
        sudo update-rc.d {name} defaults
        service {name} start
        ''').format(**locals()))

if __name__ == '__main__':
    r"""
    CommandLine:
        python ~/local/ubuntu/startup/make_initd.py
    """
    make_initd(expanduser('~/local/ubuntu/startup/log_sensors.sh'))
