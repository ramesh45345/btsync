#!/bin/bash
# BTSync Installer Script for Linux, v1.0
# Copyright 2014 vinadoros; Distributed under the LGPL v2.1
# All external code/work is copyrighted, and subject to the respective author's licenses.


# Exit if there is any error in the program.
set -e


###############################################################################
###########################        Variables        ###########################
###############################################################################

# Set home folder for current user.
HOMEFOLDER=~
# URL's from http://forum.bittorrent.com/topic/24781-latest-1282-build/
BTSYNC_64BITURL=http://syncapp.bittorrent.com/1.2.82/btsync_x64-1.2.82.tar.gz
BTSYNC_32BITURL=http://syncapp.bittorrent.com/1.2.82/btsync_i386-1.2.82.tar.gz

# Set the version of BTSYNC to use, based on 32bit or 64bit machine. Currently only works for x86 and x86_64 architectures.
MACHINEARCH=$(uname -m)
if [ "${MACHINEARCH}" = "x86_64" ]; then
    url=$BTSYNC_64BITURL
else
    url=$BTSYNC_32BITURL
fi

# Port number for BTSync web-ui
BTPORTNUMBER=8888


###############################################################################
##########################        Root Check        ###########################
###############################################################################

# This code checks to see if you are running as root/sudo. Script is not designed to run as root, however it can be done. When you go to uninstall the program, you must also run the script as root again.

if [ "$(id -u)" == "0" ]; then
    while true; do
        read -p "I have noticed you are root, or have run the script as sudo. The script is designed to run as a normal user. Only do this if you are sure you want to use the root user for BTSync. Are you sure you want to do this? Answer no if you are unsure. (y/n)" ROOTQUESTION
        case $ROOTQUESTION in
        
        [Yy]* ) 
    	echo "You asked to install BTSync as superuser/root."
    	
    	break;;
    	
    	[Nn]* ) 
    	echo "You asked not to install BTSync as superuser/root. Please exit superuser, or login as a normal user."
    	exit 1;
    	break;;
    	
    	* ) echo "Please input y (yes), or n (no).";;
        esac
    done
fi




###############################################################################
###########################        Functions        ###########################
###############################################################################


###############################################################################
# Function wgetbtsync: Get the btsync tarball and install BTSync.
###############################################################################
wgetbtsync(){
    # First test if the URL is valid.
    test_url=`curl --silent -Is $url | head -n 1 | sed -r 's/.* ([0-9]*) .*/\1/'`
    if [ "$test_url" != "200" ]; then
        echo version $1 not found.
        exit 1
    fi
    
    # If the URL is valid, get the version, and untar it.
    echo "Installing btsync from $url."
    wget --quiet $url -O - | sudo tar -C /usr/local/bin -zxv btsync
    
    }


###############################################################################
# Function installbtsyncconfig: Install local btsync configuration file.
###############################################################################
installbtsyncconfig(){
    if [ ! -d $HOMEFOLDER/.sync/ ]; then
        echo "Creating $HOMEFOLDER/.sync/"
        mkdir $HOMEFOLDER/.sync/
    else
        echo "$HOMEFOLDER/.sync/ already exists."
    fi

    if [ ! -f $HOMEFOLDER/.sync/sync.conf ]; then
        echo "Creating $HOMEFOLDER/.sync/sync.conf"
        
        # Dump a sync.conf in the user folder. It will overwrite any existing content in the sync.conf.
        cat >>$HOMEFOLDER/.sync/sync.conf <<EOL
{ 
  "device_name": "$(uname -n)",
  "listening_port" : 0,                       // 0 - randomize port
  
/* storage_path dir contains auxilliary app files
   if no storage_path field: .sync dir created in the directory 
   where binary is located.
   otherwise user-defined directory will be used 
*/
  "storage_path" : "$HOMEFOLDER/.sync",

  "check_for_updates" : true, 
/*  "use_upnp" : true,                              // use UPnP for port mapping
*/

/* limits in kB/s
   0 - no limit
*/
/*  "download_limit" : 0,                       
  "upload_limit" : 0, */

/* remove "listen" field to disable WebUI
   remove "login" and "password" fields to disable credentials check
*/
  "webui" :
  {
    "listen" : "127.0.0.1:$BTPORTNUMBER"
/*    ,"login" : "admin",
    "password" : "admin"    */
  }

/* !!! if you set shared folders in config file WebUI will be DISABLED !!!
   shared directories specified in config file
   override the folders previously added from WebUI.
*/


// Advanced preferences can be added to config file.
// Info is available in BitTorrent Sync User Guide.

}
EOL
    
    else
        echo "$HOMEFOLDER/.sync/sync.conf already exists, will not recreate."
    
    fi    

    #This section of the code creates a .desktop file so you can access the web interface through a shortcut.
    
    # Check to see if the entire folder is there.
    if [ ! -d /usr/share/applications ]; then
        echo "Creating /usr/share/applications"
        mkdir /usr/share/applications
    else
        echo "/usr/share/applications already exists. Will not create."
    fi
    
    # Check to see if btsync-user.desktop exists.
    if [ ! -f /usr/share/applications/btsync-user.desktop ]; then
        echo "Creating /usr/share/applications/btsync-user.desktop"
        
        
        # Create a desktop file in the global application entries folder. This file was modified from a version taken from https://github.com/tuxpoldo/btsync-deb/blob/master/btsync-user/scripts/btsync-user.desktop. Credit goes to tuxpoldo on github, and any other authors/contributors related.
        sudo sh -c "cat >>/usr/share/applications/btsync-user.desktop" <<EOL
[Desktop Entry]
Name=BitTorrent Sync Web UI
Comment=BitTorrent Sync management interface
Exec=xdg-open http://127.0.0.1:$BTPORTNUMBER
Icon=btsync-user
Terminal=false
Type=Application
Categories=Network
EOL
    fi
    
    
    # Get an icon as well. This file was taken from https://github.com/tuxpoldo/btsync-deb/tree/master/btsync-user/icons/. Credit goes to tuxpoldo on github, and any other authors/contributors related.
    if [ ! -f /usr/share/icons/hicolor/16x16/apps/btsync-user.png ]; then
        echo "Retreiving /usr/share/icons/hicolor/16x16/apps/btsync-user.png"
        sudo wget --quiet https://raw2.github.com/tuxpoldo/btsync-deb/master/btsync-user/icons/16/btsync-user.png -O /usr/share/icons/hicolor/16x16/apps/btsync-user.png
    fi
    if [ ! -f /usr/share/icons/hicolor/32x32/apps/btsync-user.png ]; then
        echo "Retreiving /usr/share/icons/hicolor/32x32/apps/btsync-user.png"
        sudo wget --quiet https://raw2.github.com/tuxpoldo/btsync-deb/master/btsync-user/icons/32/btsync-user.png -O /usr/share/icons/hicolor/32x32/apps/btsync-user.png
    fi
    if [ ! -f /usr/share/icons/hicolor/48x48/apps/btsync-user.png ]; then
        echo "Retreiving /usr/share/icons/hicolor/48x48/apps/btsync-user.png"
        sudo wget --quiet https://raw2.github.com/tuxpoldo/btsync-deb/master/btsync-user/icons/48/btsync-user.png -O /usr/share/icons/hicolor/48x48/apps/btsync-user.png
    fi
    if [ ! -f /usr/share/icons/hicolor/96x96/apps/btsync-user.png ]; then
        echo "Retreiving /usr/share/icons/hicolor/96x96/apps/btsync-user.png"
        sudo wget --quiet https://raw2.github.com/tuxpoldo/btsync-deb/master/btsync-user/icons/96/btsync-user.png -O /usr/share/icons/hicolor/96x96/apps/btsync-user.png
    fi


    }
    
###############################################################################
# Function installbtsyncstartup: Install btsync to run on startup as the current user.
###############################################################################
installbtsyncstartup(){
    
    # Create the systemd service.
    
    if [ ! -f /etc/systemd/system/btsync@.service ]; then
    sudo sh -c "cat >>/etc/systemd/system/btsync@.service" <<'EOL'
[Unit]
Description=BTSync for %i
 
[Service]
Type=simple
User=%i
ExecStart=/usr/local/bin/btsync --nodaemon --config %h/.sync/sync.conf
WorkingDirectory=%h
 
[Install]
WantedBy=multi-user.target
EOL

    fi
    
    # Enable the systemd service as the current user, and start it.
    sudo systemctl enable btsync@$USER.service
    sudo systemctl start btsync@$USER.service

    }


###############################################################################
# Function removebtsync: Remove all traces of BTSync produced by this script.
###############################################################################
removebtsync(){
    while true; do
        read -p "Are you sure you want to completely remove BTSync? (y/n)?: " RMQUESTION
        case $RMQUESTION in
        
        [Yy]* ) 
        echo "You asked to remove BTSync."
            
        while true; do
        read -p "Do you want to remove your existing BTSync Configuration files in your home folder? (y/n)?: " BTCONFQUESTION
        case $BTCONFQUESTION in
        
            [Yy]* ) 
            echo "You asked to remove the config files. I will delete $HOMEFOLDER/.sync"
            if [ -d $HOMEFOLDER/.sync/ ]; then
                rm -rf $HOMEFOLDER/.sync
            fi
    
            break;;
            
            [Nn]* ) 
            echo "You asked not to remove the config files."
            break;;
            
            * ) echo "Please input y (yes) or n (no).";;
        esac
        done
    
        echo "Deleting systemd startup info."  
        if [ -f /etc/systemd/system/btsync@.service ]; then
            sudo systemctl stop btsync@$USER.service
            sudo systemctl disable btsync@$USER.service
            sudo rm /etc/systemd/system/btsync@.service
        fi
        
        echo "Deleting BTSync."  
        if [ -f /usr/local/bin/btsync ]; then
            sudo rm /usr/local/bin/btsync
        fi

        # Delete the application icon and desktop file too.
        echo "Deleting BTSync shortcuts." 
        if [ -f /usr/share/applications/btsync-user.desktop ]; then
            sudo rm /usr/share/applications/btsync-user.desktop
        fi
        if [ -f /usr/share/icons/hicolor/16x16/apps/btsync-user.png ]; then
            sudo rm /usr/share/icons/hicolor/16x16/apps/btsync-user.png
        fi
        if [ -f /usr/share/icons/hicolor/32x32/apps/btsync-user.png ]; then
            sudo rm /usr/share/icons/hicolor/32x32/apps/btsync-user.png
        fi
        if [ -f /usr/share/icons/hicolor/48x48/apps/btsync-user.png ]; then
            sudo rm /usr/share/icons/hicolor/48x48/apps/btsync-user.png
        fi
        if [ -f /usr/share/icons/hicolor/96x96/apps/btsync-user.png ]; then
            sudo rm /usr/share/icons/hicolor/96x96/apps/btsync-user.png
        fi
        
        break;;

        [Nn]* ) 
        echo "You asked not to remove BTSync."
        break;;
        
        * ) echo "Please input y (yes) or n (no).";;
    esac
    done

    }


###############################################################################
##########################        Main Program       ##########################
###############################################################################


while true; do
    read -p "Do you want to install (i) BTSync for the first time, update (u) an existing install, remove (r) BTSync, or exit(e)? (i/u/r/e)?: " QUESTION
    case $QUESTION in
    
        [Ii]* ) 
        echo "You asked to install BTSync for the first time on this machine."
        
        if [ -f "/etc/systemd/system/btsync@.service" -o -f "/usr/local/bin/btsync" -o -f "/usr/share/applications/btsync-user.desktop" ]; then
            echo "I have detected existing BTSync files. You will now be asked if you want to remove any previous BTSync files."
            removebtsync
        fi
        
        wgetbtsync
        installbtsyncconfig
        installbtsyncstartup
        break;;
        
        [Uu]* ) 
        echo "You asked to update BTSync."
        # Stop the BTSync service, update BTSync, start it again.
        sudo systemctl stop btsync@$USER.service
        wgetbtsync
        sudo systemctl start btsync@$USER.service
        break;;
        
        [Rr]* ) 
        echo "You asked to remove BTSync."
        removebtsync
        break;;
        
        [Ee]* ) 
        echo "You asked not to install, update, or remove BTSync."
        break;;
        
        * ) echo "Please input i (install), u (update), r (remove), or e (exit).";;
    esac
done



