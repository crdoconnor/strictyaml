# Development and test environment

## Running on Mac

To run integration tests / environment on a Mac:

* Install XCode from the Mac App store, if not already installed.
* Run "xcode-select --install"
* Install brew if not already installed -- instructions here : http://brew.sh/
* Run:

```bash
$ brew install python python3

$ sudo pip install --upgrade hitchkey virtualenv
```

Git clone the repository somewhere new (e.g. a temporary directory) and switch to the branch you want.

Then:

```bash
$ hk regression
```

## Running on Linux

To set up:

```bash
$ sudo apt-get install python3 python-pip python-virtualenv

$ sudo pip install --upgrade hitchkey
```

Then:

```bash
$ hk regression
```
