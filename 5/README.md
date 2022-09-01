QUICK & EASY NODE & VALIDATOR INSTALLATION GUIDE FOR HETZNER

Head over to the AMD Ryzen dedicated server page at https://www.hetzner.com/dedicated-rootserver/matrix-ax and order the AX41 dedicated server:

![image](https://user-images.githubusercontent.com/23145642/187998813-2e4133f5-947c-4844-bcbf-328e9610fcfc.png)

Click CONFIGURE, choose Finland for the data center location and Ubuntu 22.04 LTS for the operating system.  Place the order by clicking ORDER NOW and provide the usual personal and payment details.  Once your order is processed (can take up to 24 hours and they may also require KYC if you have no prior payment history with them), they will e-mail you the server details, including the password to login to the root account.

You will need a terminal emulator to login to your new dedicated server.  The free version of Mobaxterm is recommended.  You can download it at https://mobaxterm.mobatek.net/download.html

Once installed, open up Mobaxterm and create a new session:

![image](https://user-images.githubusercontent.com/23145642/187999957-48339c0f-1a4c-490d-ab24-cf749187b162.png)

Select SSH:

![image](https://user-images.githubusercontent.com/23145642/188000096-d35d1255-afd0-4fce-a91a-bab62a07b6e6.png)

In the SSH session settings, enter the numerical IP of the server that Hetzner e-mailed you and specify root as the username:

![image](https://user-images.githubusercontent.com/23145642/188000298-241a6521-e0dd-41a1-94ca-62c5fc18a458.png)

Select OK.  The dialog will close and notice that the saved SSH session is under User sessions on the left menu pane.  Double click it to login and when it asks, copy and paste the root password from the Hetzner e-mail.  In Mobaxterm, dragging to highlight text with the left mouse button automatically copies to the OS clipboard; likewise pressing the right mouse button will automatically paste what is in the OS clipboard.  So on Windows, you can use the left mouse button to drag and highlight the root password, press CTRL C to copy it to the OS clipbard and then switch to Mobaxterm -- first left click on the console screen before pressing the right mouse button to paste.

Once you've sucessfully logged into your root account similar to the screenshot below:

![image](https://user-images.githubusercontent.com/23145642/188002670-c6147248-daef-4ce3-a4cc-33117030dbb0.png)

...copy and paste the entire chunk below into a text editor and edit the USERNAME to be the preferred name of the user account where NEAR will actually run.  Then copy and paste the entire chunk in the console:

```
USERNAME=youruseraccountnamehere
####
sudo apt -y update && sudo apt -y install apg
sed -i 's/%sudo\tALL\=.*/%sudo\tALL\=\(ALL:ALL\) NOPASSWD: ALL/' /etc/sudoers
useradd -m -s /bin/bash -G adm,systemd-journal,sudo $USERNAME
echo "password required pam_unix.so sha512 shadow nullok rounds=65536" >> /etc/pam.d/passwd
password=$(apg -m 43 -a 1 -n 1)
(echo $password; echo $password) | passwd $USERNAME
echo "User Password: $password"
```

![image](https://user-images.githubusercontent.com/23145642/188006237-1d8d6c28-c53d-4a4c-aa3a-daeae687e815.png)

The above will update the package repository, install a password generator, allow user accounts to have root access without being prompted for a password, create a user account with appropriate group permissions, increase the security of all stored passwords, generate a random password for that user account and then output a password to the console.  Make sure you copy and paste that password somewhere safe as it will be needed in the next step (Mobaxterm can remember passwords for you if enabled.)

Then reboot the machine with:

```
sudo reboot
```

![image](https://user-images.githubusercontent.com/23145642/188006633-8ddd56cd-2fa9-4d23-8b62-94e2ab70143f.png)

Eventually the SSH session will disconnect (you may have to press enter once or twice).  Select and highlight the saved SSH session under User sessions on the left menu pane, right click and select Edit session.  Change the username to the one you decided on earlier and click OK.  Close the stopped SSH session tab:

![image](https://user-images.githubusercontent.com/23145642/188007633-ca7be2f2-0ca7-499c-9eb1-9d079f1e2498.png)

Then double click the saved SSH session on the left manu pane to login to the server with the new credentials.  Normally you could just press R in a stopped seassion tab to relogin with the same account.

Once logged into the user account, install wget to download two script files:

```
sudo apt -y install wget
wget https://raw.githubusercontent.com/joesixpack/stakewars-iii-challenges/main/5/createnode.sh -O createnode.sh
wget https://raw.githubusercontent.com/joesixpack/stakewars-iii-challenges/main/5/createpool.sh -O createpool.sh
chmod +x createnode.sh createpool.sh
```

![image](https://user-images.githubusercontent.com/23145642/188010838-9f325049-1709-450b-9217-090d50f0aaa8.png)

Decide on a public moniker to use for your signing wallet and validator pool, then run:

```
./createnode.sh moniker
```

This script will compile, install, initialize, autostart and autorun 24/7 a new NEAR node, install NEAR-CLI to interact with the chain, install node monitoring tools (accessible via browser at http://yourserverIP:3000), as well as install a firewall with only the necessary ports opened.

![image](https://user-images.githubusercontent.com/23145642/188021509-2f9ad25c-f0cf-48b5-875c-91444c3da63b.png)

Say yes to this prompt:

![image](https://user-images.githubusercontent.com/23145642/188024628-1de3df50-51a6-4c64-9b19-2d89e3c9a1e3.png)

A backup copy of your node and validator keys have been archived as moniker.factory.shardnet.near.tar.gz in your user home directory.  These keys are necessary to restore your node and validator (to be setup later).  If you re-run this script, it will check for this archive to pe present and extract the keys instead of creating new ones.

At this step, enter 1 or enter:

![image](https://user-images.githubusercontent.com/23145642/188014037-4b8a1950-6dd9-4ef5-a048-e72fdf761c42.png)

If you see any screens like this (should be at least five), just press enter:

![image](https://user-images.githubusercontent.com/23145642/188014257-fa6ed042-d168-4c1f-b616-a032a9debb17.png)

Once the script finishes, monitor the running NEAR node's log output with:

```
sudo journalctl -fu neard -o cat | grep INFO
```

The node will be full synced when it is no longer downloading headers or blocks (they reach 100%):




Once the node is fully synced, create a signing wallet for NEAR-CLI using the moniker you picked earlier at https://wallet.shardnet.near.org/.  

![image](https://user-images.githubusercontent.com/23145642/188026474-fed90139-181a-4f2a-852b-47ad8f3e9324.png)

Once that is done, you will need to download the wallet signing keys to your server so NEAR-CLI can access it:

```
near login
```

Copy the URL given and paste it into your browser.  Grant full access to NEAR-CLI in the resulting popup, using the format moniker.shardnet.near which is now your signing wallet.

![image](https://user-images.githubusercontent.com/23145642/188027581-c46d2889-98b5-497c-87ae-062ca0ae268e.png)

You will then see an error page:

![image](https://user-images.githubusercontent.com/23145642/188027810-ba0a9622-af85-4d33-b1c1-4dfe9f82530a.png)

...but now go back to the console and type in or paste your moniker.shardnet.near signing wallet:

![image](https://user-images.githubusercontent.com/23145642/188027322-61a59a0e-8b5d-4b16-bd84-074144660ccc.png)

And now for the very last step!  To create your validator pool, it will cost 30 NEAR as a storage reserve fee, plus gas, plus your initial stake amount.  Depending on how much you NEAR have in the signing wallet after creation (usually 50) and/or received from frens, 40 is a good minimum initial amount to leave enough gas for future transactions.

```
./createpool.sh amount
```

This will takea couple of minutes.  Once that is done, you're good to go!  Your critical information:

```
Signing Wallet (aka Account ID): moniker.shardnet.near
Validator Pool ID: moniker.factory.shardnet.near

Location of Node & Validator Keys: ~/.near/
Location of Node & Validator Keys Backup: ~/moniker.factory.shardnet.near.tar.gz

Location of Signing Wallet Key: ~/.near-credentials/shardnet/moniker.shardnet.near
```

~ means the top level of the user account directory and also a shortcut for $HOME which points to the same thing.
