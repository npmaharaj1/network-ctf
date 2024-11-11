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

<b>Client side authentication vs Server side authentication. What is it and why does it matter?</b>
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


