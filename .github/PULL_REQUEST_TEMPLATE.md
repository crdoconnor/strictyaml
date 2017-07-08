Qualities of an ideal pull request:

Code changes come with a new story or an amendment to an existing story
in order to exercise the code.

Commit messages that adhere to the following pattern:

TYPEOFCOMMIT : Quick explanation of what changed and why.

Where TYPEOFCOMMIT is one of the following:

* FEATURE - for new features and accompanying stories.
* BUG - for bugfixes and accompanying stories (or amendments to an existing story).
* DOCS - for changes to README, etc. and non-functional changes to stories.
* MISC - Anything else.

Ideal code qualities:

* Loosely coupled
* DRY
* Clear and straightforward is preferable to clever
* Docstrings that explain why rather than what
* Clearly disambiguated Variable/method/class names
* Passes flake8 linting with < 100 character lines
