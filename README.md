area31-ebuilds
================

1- RTFM

http://www.funtoo.org/Local_Overlay

2- Get this overlay:

~~~~
# mkdir -p /var/overlay ; cd /var/overlay
# git clone https://github.com/area31/area31-ebuilds.git
# mv area31-ebuilds /var/overlay
~~~~


3- Configure /etc/make.conf:

~~~~
# echo 'PORTDIR_OVERLAY="/var/overlay/area31-ebuilds/local"' >> /etc/make.conf
~~~~

4- Update your database:

~~~
# emerge app-portage/eix
# eix-update
~~~

5- Keep updated:

# cd /var/overlay/area31-ebuilds && git pull
