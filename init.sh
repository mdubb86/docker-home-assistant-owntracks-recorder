#!/usr/bin/with-contenv /bin/bash
echo 'Initializing OwnTracks recording container'
test -f /env && source /env
sed -i "s/<SERVER_NAME>/$SERVER_NAME/" /etc/nginx/sites-available/publish
rm -rf /owntracks_publish.htpasswd
htpasswd -b -c /owntracks_publish.htpasswd $USER $PASSWORD
