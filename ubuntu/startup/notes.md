-------------------------------------------------------------------------------
# Topic: standard directories


* `/etc` - stands for "et cetera" - Usually contain the configuration files for
  all the programs that run on your Linux/Unix system


* `/sbin`: stands for system binaries - stores executables made available only
  to the root user. This contains executable programs needed to boot

  System administrative programs that are not required until the `/usr` filesystem
  has been mounted (i.e., logically attached to the system) during system startup
  are usually located in `/usr/sbin`. Confusingly, some system administration
  executables may instead reside in `/usr/local/sbin`.


* `/var` - stands for variable - is a place where a lot of logs, caches, BUT
  also program variable settings files and even some system configuration
  databases reside. This directory contains system information data describing
  the system since it was booted.

* `/var/run` - Run-time variable data - This directory contains system
  information data describing the system since it was booted. Files under this
  directory must be cleared (removed or truncated as appropriate) at the
  beginning of the boot process. Programs may have a subdirectory of /var/run;
  this is encouraged for programs that use more than one run-time file.

* `/usr` - The secondary hierarchy which contain its own bin and sbin
  sub-directories.

* `/opt` - Third party application packages which may not conform to the
  standard Linux file hierarchy can be installed here.

* `/srv` - Contains data for services provided by the system.


#### References:
* [►](http://www.pathname.com/fhs/2.2/fhs-5.13.html)
* [►](http://www.aboutlinux.info/2007/03/what-does-etc-stands-for-in-linuxunix.html)
* [►](http://www.linfo.org)
* [►](http://www.linfo.org/var.html)
* [►](http://www.linfo.org/sbin.html)


-------------------------------------------------------------------------------
# Topic: systemd

Post Ubuntu 15.04: with systemd, there is a new functionality called
tmpfiles.d(5)  The tmpfiles configuration files are stored in
/usr/lib/tmpfiles.d/

```
ls /usr/lib/tmpfiles.d/
man tmpfiles.d
```

With the adoption of systemd as of 15.04, there is now a centralized mechanism
for the creation of temporary files and directories such as these.  Place .conf
files in /usr/lib/tmpfiles.d (or /etc/tmpfiles.d, /run/tmpfiles.d)

A service wishing to use this method can remove  mkdir commands in its own
startup script and instead place a .conf file in /etc/tmpfiles.d,
/run/tmpfiles.d, or /usr/lib/tmpfiles.d, with Ubuntu services seeming to prefer
the last option. For example, my system now has:

#### References: 

* [►](https://askubuntu.com/questions/303120/how-folders-created-in-var-run-on-each-reboot)
* [►](https://serverfault.com/questions/824393/var-run-directory-creation-even-though-service-is-disabled/824394#824394)
