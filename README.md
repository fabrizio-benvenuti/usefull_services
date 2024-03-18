# usefull_services
usefull services for an ubuntu server

# Usage
* copy  all the abc.service and abc.timer files of all the timered services you want to add to your server into your /etc/systemd/system/ directory
* copy all the efg.service files of all the untimered services you want to add to your server into your /etc/systemd/system/ directory
* run
``` bash
  sudo systemctl daemon-reload
```
* run for every abc.timer you imported 
``` bash
  sudo systemctl enable abc.timer
```
* run for every __UNTIMERED__ efg.service you imported 
``` bash
  sudo systemctl enable efg.service
```
