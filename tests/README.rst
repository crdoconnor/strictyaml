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

    $ pip install --upgrade hitch virtualenv

Git clone the repository somewhere new (e.g. a temporary directory) and switch to the branch you want.

Then::

    $ cd tests/

    $ hitch init

    $ hitch test map.test --settings tdd.settings


Running on Linux
================

To set up::

    $ sudo apt-get install python3 python-pip python-virtualenv

    $ sudo pip install --upgrade hitch

Then::

    $ cd tests

    $ hitch init

    $ hitch test map.test --settings tdd.settings

Troubleshooting
===============

If something goes wrong during set up you can do the following:

* Note that if you see some assertion errors during hitch init they can *safely be ignored*.
* Try running the test again if it fails a first time.
* Try running hitch clean and hitch cleanpkg and then running hitch init / hitch test again.
* Email me with the stacktrace (crdoconnor@gmail.com) if you can't figure out why it's failing.