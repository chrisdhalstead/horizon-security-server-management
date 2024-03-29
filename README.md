### horizon-security-server-management

Script to manage VMware Horizon Security Servers via the View-API

***<u>There is no support for this tool - it is provided as-is</u>***

Please provide any feedback directly to me - my contact information: 

Chris Halstead - Senior Staff Architect, VMware  
Email: chalstead@vmware.com  
Twitter: @chrisdhalstead  <br />

Thanks to Andrew Morgan for the assistance!  @andyjmorgan<br />

Updated May 21, 2021<br />

------

### Problem Overview

Due to the deprecation of Adobe Flash on 12/31/20 the VMware Horizon 7 Administrator (FLEX) will no longer be able to be used.  More details are here:  https://kb.vmware.com/s/article/78589

It is recommended to get to a minimum of VMware Horizon 7.10 (Version 7.13 is recommended) which has an HTML5 based administrative console (Horizon Console) with feature parity with the FLEX console.  There are only two features that were not ported to this new HTML5 administrative console

- ThinApp integration into Pools (ThinApp still works)
- Security Server Management

It is recommended to move off the Horizon Security Server to the [Unified Access Gateway](https://techzone.vmware.com/deploying-vmware-unified-access-gateway-vmware-workspace-one-operational-tutorial) as the Security Server is no longer supported in Horizon 8 and it is a superior solution for providing remote access.   If you have existing Horizon Security Servers there is no way to manage them with the new Horizon Console HTML5 console.   This script can be used to manage those existing Security Servers and create a Security Server Pairing password.  These are the two features needed for adding and updating Security Server.

### Preparing Security Server for Upgrade or Reinstallation

If you need to upgrade your security server and are looking for the "Prepare for Upgrade or Reinstallation" button in the admin console - it is no longer there.  Thankfully, the solution is just a matter of removing IPsec rules on both the Security Server and the Connection Server that it is paired with.

1. Start > Control Panel > Windows Firewall

2. In the left pane, click Advanced Settings

3. Expand Windows Firewall with Advanced Services and select Connection Security Rules

4. In the right pane, select VMware View Security Server QM Pairing with xxx.xxx.xxx.xxx.  Select this rule and delete it.

Do that on both the security server and the connection server it's paired with.  Then you can upgrade your security server.

Reference:  https://communities.vmware.com/t5/Horizon-Desktops-and-Apps/Security-Server-Upgrade-Problem/td-p/395429 

### Script Overview

This is a PowerShell script that uses PowerCLI and the View-API to query and set the Security Server settings.  For more information on how to setup PowerCLI check out [this great article by my colleague Graeme Gordon](https://blogs.vmware.com/euc/2020/01/vmware-horizon-7-powercli.html).  There are two functions that the script can be used for.

- Setting the Security Server Pairing Password on the Connection Server you authenticate to
- Retrieve a list of Security Servers bound to the Connection Server you authenticate to
  - This is a GUI and looks very similar to same management page in the FLEX console

### Script Usage

1. Run `Horizon - Manage Security Server.ps1` 


   ![Menu](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/Menu.PNG)

   #### Login to Horizon Connection Server

2. Choose **1** to Login to a Horizon Connection Server 

   - Enter the FQDN of a connection server  (<u>**NOT a Security Server**</u>) when prompted to "Enter the Horizon Server Name" hit enter.  If you want to set a Security Server pairing password, enter the name of the Connection Server you want to pair here.

   - Enter the Username (samAccountName) of an account with Administrative access to the Horizon Server you are connecting to when prompted to "Enter the Username" hit enter

   - Enter that users Password and click enter

   - Enter that users Domain and click enter

     You will see that you are now logged in to Horizon - click enter to go back to the menu


     ![cs](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/login.PNG)

#### Manage Security Servers

1. Enter **3** to manage and update the Horizon Security Servers bound to the connection server you logged in to - this will open up a GUI
   The GUI may behind other windows if you don't see it after hitting 3 on the menu.

   *Note: If there are no connection servers detected you will see a message in the console "No Security Servers Found"*


   ![gui](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/gui.PNG)

   

2. If there are Security Servers bound they will all be added to the "Security Servers" dropdown.  If there are none - you will see "No Security Servers"
   
3. Select the Security Server you would like to manage and click "Get Details" - this will populate the form.


   ![viewss](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/viewss.PNG)

   

4. Review and click the "Cancel" button to exit without changing .  You can also select different Security Servers and click "Get Details"
   
5. To update the settings make changes to any fields you would like to update and click "OK".  You will be prompted if you would like to update that Security Server.  Click "Yes" to make the changes or "No" to exit without making changes.  All three value must NOT be empty.  They are required fields and you will get a warning message if you try to set an empty value
   


   ![update](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/update.PNG)![saved](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/saved.PNG)

   

6. Make any other changes and click "Cancel" when ready to Exit.

   #### Set Security Server Pairing Password

   ***This section is only needed when adding a new security server.  It is recommended to migrate to the Unified Access Gateway. Only use the Security Server if you absolutely have to***

   **Make sure that you connected to the Connection Server you want to set the Security Server pairing password for with this script.**

   In order to add a new Security Server - you need to specify a pairing password for one-time authentication to the connection server.   This password is good for 30 minutes and just a one-time password.  This script allows you to set that password.  

   **Make sure the Timezone of the connection server that you will connect to with the script is set to <u>(UTC) Coordinated Universal Time</u> prior to running the script on it**

   **Any other variant of the UTC time zone will not work**

     ![Timezone](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/Timezone.PNG)

   > While putting together the script I realized that the `pae-securityserverpairingpasswordlastchangedtime` parameter in the ADAM database which is used to determine when the password was last set and used to compare to the validity time is not being set properly if you connection server is not using the UTC time zone.  If you leave the connection server to a non UTC time zone and run this script the password last set time will be the time zone of the connection server which almost certainly deem the password invalid.  If your connection server is in a time zone other than UTC you will need to set to set it to the UTC time zone, restart the "VMware Horizon View Connection Server" service.  Run the script to set the password, then you can change the time zone on the connection server back.
   
   - Enter **2** to specify a Security Server pairing password.
   
   - You will see a pop up warning you that the Connection Server time zone needs to be set to UTC while running this script (see above)
   
   - Enter the password you would like to use and hit enter
   
   - The password will be set and is good for 30 minutes


     ![ssppw](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/ssppw.PNG)

   You can now install a Security Server and specify the Pairing Password you set in the script.

**Troubleshooting:**

If the script hangs after entering credentials, you are most likely running PowerShell 7.x, this script has a problem with 7.x and works best with PowerShell 5.x.

You can verify the password was set properly by [connecting to the ADAM database](https://kb.vmware.com/s/article/2012377) on the server you set the password on.

 ![ssppw](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/ADAM2.png)

- Navigate to OU=Properties | OU=Server | Double-Click the Server name you set the password on and navigate to:
  - `pae-SecurityServerPairingPassword` - this should have an encrypted value
  - `pae-SecurityServerPasswordLastChangedTime` - This is the important value, to make sure that when you double-click on it the UTC time is less that 30 minutes from the current time in UTC
  - `pae-SecurityServerPairingPasswordTimeout` - This should be set to 1800 (30 minutes) if the password was set with this script.

 ![ssppw](https://github.com/chrisdhalstead/horizon-security-server-management/blob/master/Images/ADAM1.png)





















