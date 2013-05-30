#Pivotal

##What is Pivotal?
Pivotal is a simple command line application that lets me automate a bunch of tasks I need to do when starting a new story. It's really, really not flexible at all right now, so it probably won't work well for you. I'll probably change that, and add more config options in the future.

##Installation
Installation isn't the easiest at the moment, but I'm working to fix that.
First, you want to clone this repository somewhere in your local filesystem, and cd into it
```bash
git clone git@github.com:chintanparikh/pivotal.git
cd pivotal
```
Next, copy pivotal into a folder in your PATH, typically /usr/bin
```bash
sudo cp pivotal /usr/bin/
```
and chmod it to make it executable
```bash
sudo chmod u+x /usr/bin/pivotal
```

##Usage
Look at the code, I'll type up some documentation when the code isn't fugly and in desperate need of a refactor