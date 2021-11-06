# px4_install
Script to install PX4 firmware v1.10.1

## run command inside directory 
```
./setup_px4.sh
```

### in the screen will show like below

________________________________________________

```
NOTE: must run this script in the px4 setup directory  

Input PATH to install PX4 firmware:  

(e.g., /home/USERNAME/ros/px4/.): 
```
________________________________________________ 

type the path to the directory that want to put Firmware into

example here I've already created `px4` directoy in `home`

**note, it must be absolute path**, here it will be: `/home/congtranv/px4/.`

enter your path and it will ask you to confirm your path again 

type y (or Y, yes, YES) for script starting install 

it needs root credentials to perform some command, please type your password 

and it will do itself until done 

**NOTE** if have issues related to python tool, let install recommended packages or use conda base environment
