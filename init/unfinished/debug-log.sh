echo "
installs tools and scripts to monitor and log system information for crash
debugging

References:
    https://help.ubuntu.com/community/DebuggingSystemCrash

    https://wiki.ubuntu.com/Kernel/CrashdumpRecipe?action=show&redirect=KernelTeam%2FCrashdumpRecipe

    https://askubuntu.com/questions/96957/where-can-i-find-the-log-file-of-my-system-temperature

    https://anturis.com/blog/how-to-set-up-continuous-cpu-temperature-monitoring-for-linux-servers-for-free/

    https://github.com/groeck/nct6775/issues/51

    https://askubuntu.com/questions/860156/ubuntu-crashes-with-blank-screen

    https://askubuntu.com/questions/389084/system-testing-tool-for-ubuntu
" > /dev/null


https://github.com/sysstat/sysstat
sudo apt-get install sysstat


sudo apt install sensord lm-sensors dateutils gnuplot
sudo apt install superiotool


sudo sensors-detect

/etc/init.d/kmod start

sensors


sudo apt-get install checkbox-gui
sudo apt-get install checkbox-qt
sudo apt-get install phoronix-test-suite

python error: Function not found: 'checkbox_touch.get_qml_logger' 
python error: Function not found: 'checkbox_touch.create_app_object' 
NameError: name 'checkbox_touch' is not defined.

python error: Cannot import module checkbox_touch
File "/usr/share/checkbox-converged/py/checkbox_touch.py", line 44 in module from plainbox.abc import IJobResult
No module named 'plainbox'


scrap(){
    # Looking into setting up systemd with journalctl to do standard linux logging of info
    systemctl status
}


print_sensor_logs(){
    journalctl -u sensord
}

ensure_systemd_persistant_storage(){
    # https://gist.github.com/JPvRiel/b7c185833da32631fa6ce65b40836887
    #if [ ! -d /var/log/journal ]; then
    #    sudo mkdir -p /var/log/journal
    #    sudo systemd-tmpfiles --create --prefix /var/log/journal
    #    sudo systemctl restart systemd-journald
    #fi
    # OR:
    # https://doc.opensuse.org/documentation/leap/reference/html/book.opensuse.reference/cha.journalctl.html
    # edit the config file
    # man journald.conf
    cat /etc/systemd/journald.conf
    set-journal-config()
    {
        key=$1
        value=$2
        sudo sed -i "s/ *#* *$key=.*/$key=$value/" /etc/systemd/journald.conf
    }
    set-journal-config "Storage" "persistent"

    # Restart the systemd journal service
    sudo systemctl restart systemd-journald

}
