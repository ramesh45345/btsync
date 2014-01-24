btsync
======

<h2><b>BTSync Installer Script for Linux</b></h2>

This is an installer script for Bittorrent Sync for linux. There are several out there, but this one was created for a few specific reasons:<br>

<ol>
<li>This script would work on multiple linux distros. Packages have been made for debian/ubuntu by tuxpoldo, however there isn't a very good solution for Fedora, OpenSUSE (I believe an rpm exists for OpenSUSE, but I can't remember for sure), or other distros.</li>
<li>No automatic solution currently creates a systemd service for autmomatically starting BTSync on startup.</li>
<li>Few solutions allows for an easy install, uninstall, or upgrade (a notable exception is tuxpoldo's work, and it only works on debian/ubuntu based distros).</li>
</ol>

This script was created to be generic, and run on any distro that supports systemd (the only reason it only supports systemd is that I don't yet have an idea about making an rc script and detecting between normal init and systemd. Contributions for that are very welcome).

<h4><b>How to use the script:</b></h4>

<ul>
<li>Execute the script using <code>sh ./BTSync_Installer.sh</code> as a normal user.</li>
<li>Ensure that no other instances of btsync are present on the system. There could be conflicts.</li>
<li>Use the script as a normal user. Do not run the script as root unless you have a very specific reason to do so.</li>
<li>The script creates a shortcut under either "Internet" or "Applications" depending on your system. It will load the default browser to check on the BTSync instance. </li>
<li>The script automatically starts BTSync on startup by creating a service (using the user who installed it), and starting it up immediately.</li>
<li>There is no password for using the web interface, you can set one up though.</li>
<li>Ensure that you install, upgrade, or remove BTSync with the same user who performed any other operations with this script. Don't run the script as a user, and use the remove function as root. It will not work.</li>
</ul>

<h4><b>Technical Detail of the Script:</b></h4>

<ul>
<li><b>Install Mode</b>: Checks to see if BTSync exists already. If it does not, it will get the BTsync tarball from the web, install it in /usr/local/bin, create a systemd service and run it, and create a configuration in ~/.sync/sync.conf in your home folder. It will also create a shortcut and icon in your application menu (shortcut and icon is taken from tuxpoldo's work on Github, see here: <a>https://github.com/tuxpoldo/btsync-deb</a>).</li>
<li><b>Upgrade Mode</b>: It only gets a version of BTSync specified in the URL fields, and replaces the version in /usr/local/bin. It doesn't do anything else.</li>
<li><b>Remove Mode</b>: It stops and removes the systemd service, removes the binary in /usr/local/bin, removes the shortcuts and icons, and at your discretion will remove your configuration.</li>
</ul>

<h4><b>Limitations:</b></h4>

<ul>
<li>Currently the script only works with a computer that has systemd. I tested the script on Fedora, OpenSUSE, and Debian (specifically the Siduction distribution, which had systemd running on it). It wouldn't be a tremendous effort to get it to run on sysvinit, but I'd need some help with the script in order to implement that. I can also have it run on other init systems (like Upstart), if I get some hints about how to make a service.</li>
<li>The script runs as a normal user. This is to make the permissions of using and accessing locations through BTSync the same as the user's permissions. This can lead to odd behavior on mounted drives, which may need root permissions to access the contents. Make sure mounted drives are owned by your user, or at least give permissions for your user to read and write.</li>
<li>Right now the URL's this script uses are hardcoded to a specific version of BTSync. Can anyone provide links to the linux versions which always point to the latest version of BTSync? Either that or some hints about how to detect the version number and insert it into the url would be helpful. Otherwise, you'll have to manually replace the URL when a new version comes out.</li>

