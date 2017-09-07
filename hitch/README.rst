Tests
=====

Running on Mac
--------------

To run integration tests / environment on a Mac::

1) Install XCode from the Mac App store, if not already installed.
2) Run "xcode-select --install"
3) Install brew if not already installed -- instructions here : http://brew.sh/
4) Run::

    $ brew install python python3

    $ pip install --upgrade hitchkey virtualenv

Git clone the repository somewhere new (e.g. a temporary directory) and switch to the branch you want.

Then::

    $ hk regression


Running on Linux
================

To set up::

    $ sudo apt-get install python3 python-pip python-virtualenv

    $ sudo pip install --upgrade hitchkey

Then::

    $ hk regression
