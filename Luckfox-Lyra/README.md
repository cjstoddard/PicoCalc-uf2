# PicoCalc Luckfox Lyra Mod

Note: In case you have never used the nano text editor, once you have finished editing a file, press Ctrl-x, y, ENTER. This will save the file and exit nano. 

The Linux build for the Lyra auto boots to tmux running a command launcher. This is fine for what it does, but I prefer a more traditional Linux login process, I don't need any hand holding. Second, it automatically logs you into the root account, which is a bad practice, don't do it and if you do, I don't want hear hear about it when you inevitably screw up you operating system. To fix these two problems, we need to do a few steps. First we need to setup a non root user login. Substitute the user name you want to use with all occurances of "username".

> mkdir /home
>
> adduser username

Next we need to change the autologin to the new user account.

> nano /etc/autologin.sh

Change the file from this;

> #!/bin/bash
>
> /bin/login -f root

to look like this;

> #!/bin/bash
>
> #/bin/login -f root
>
> /bin/login -f username

Now we need to add the user to the list of users who can use sudo, to get root access.

> nano /etc/sudoers

Look for this line towards the bottom of the file;

> root ALL=(ALL:ALL) ALL

Right underneath it, add this line;

> username ALL=(ALL:ALL) NOPASSWD: ALL

Now reboot the system and you will be brought to a traditional Linux command line. If you need to run the command-launcher as root to do things like start the Wifi or the sound, run this command;

> sudo su -

Do that now and choose bash.sh from the menu and exectute these commands;

> cp command-launcher/system/*.sh /usr/local/bin
>
> cp command-launcher/wifi/*.sh /usr/local/bin
>
> cp command-launcher/sound/*.sh /usr/local/bin
>
> chown root:root /usr/local/bin/*.sh

This will place the setup commands somewhere your user account can run them. You will need to fix wifi-up.sh so it properly calls sync-time.sh.

> nano /usr/local/bin/wifi-up.sh

Go to the last line and change;

> ./sync-time.sh

to

> /usr/local/bin/sync-time.sh

Now you need to update your path to include /usr/local/bin, and add a bit of color to your prompt with these commands.

> echo 'PATH="/usr/bin:/usr/sbin:/usr/local/bin"' >> /etc/profile
>
> echo 'export PATH' >> /etc/profile
>
> echo "PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '"  >> /etc/bash.bashrc

Now it is time to reboot the system again. Type exit and press enter, you should go back to the command-launcher. Go down to system and press enter, then choose reboot.sh and press enter. The system should reboot and when it comes back up, you should be logged into you new user account. To connect to your network type "sudo wifi-up.sh" and press enter. You should be good to go.

