---
title: Why avoid using environment variables as configuration?
---

The use of "environment variables as configuration" is recommended by
"[12 factor](https://12factor.net/config)". While this is a common
practice and often leads to few or no problems, calling it a best
practice is a bit much.

The reason cited by the 12 factor website for using them is:

>The twelve-factor app stores config in environment variables (often shortened to env vars or env). Env vars are easy to change between deploys without changing any code; unlike config files, there is little chance of them being checked into the code repo accidentally; and unlike custom config files, or other config mechanisms such as Java System Properties, they are a language- and OS-agnostic standard.

Two of these are fine reasons. It is true that these are both good reasons:

- Easy to change between deploys.
- Language and OS agnostic.

However, neither of these things requires that config be stored in environment variables.
It's easy enough to create language and OS agnostic configuration files
(INI, YAML, etc.) and it's usually straightforward to make files easy to change
between deployments too - e.g. if a deployment is containerized, by mounting the file.

It is less true that environment variables are inherently "easier" to change between
deployments - writing a file is not intrinsically difficult unless it is *made*
difficult (e.g. a file is baked in to a container image rather than being mounted), it
isn't hard to change.

Moreover, there are several disadvantages to using environment variables
that tend to exhibit themselves nastily when the size of the configuration grows beyond
a certain point.


## Environment variables are global state

Environment variables are a form of global state. Every variable
is associated only with the environment. The variables will be shared with many
other variables which have a multitude of different uses:

- The chances of variable cross contamination is high - accidentally naming one variable the same as another which is unknowingly used for a different purpose (e.g. PATH) is elevated, and this can have both weird, hard to debug and terrible effects.
- If you need to inspect environment variables e.g. to find one that you thought was there and it actually missing, tracking it down is a pain.

Global state in and of itself isn't a "bad thing" but *too much* global
state is a very bad thing. A small amount of configuration (e.g. less than
10 variables) can often be placed in to environment variables with very
little harm, but as soon as the amount grows the danger of the global
state grows.


## Environment variable values cannot handle structures more complex than a string

Environment variables are a set of key-value pairs where the key is almost always an
uppercase string and the value is always a string.

While this is more than sufficient for many purposes, there are many kinds of situations
where the configuration data that needs to be stored requires something a bit more
complicated than just a string.

Where developers run in to this limitation they have a tendency to create an ugly substructure with
cryptic codes within the string.

The way that LS_COLORS is used is a good example:

```
rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
```

Clear as mud, right?

(This isn't actually an example of 12 factor being followed assiduously, but I have seen many examples
just like it where it was).

In [StrictYAML](https://hitchdev.com/strictyaml) the following could be represented as:

```yaml
# Special

di: 01;34      # directory is blue

# Extensions

*.tz: 01;31    # red
*.flv: 01;35   # purple
```

While the codes are cryptic and probably should be changed (e.g. directory: blue), the cryptic nature
can at least be easily explained with comments.


## Creating naming conventions to handle the inability to handle

A common example:

>PERSONNEL_DATABASE_HOST, PERSONNEL_DATABASE_PORT, PERSONNEL_DATABASE_NAME, PERSONNEL_DATABASE_PASSWORD, FACTORY_DATABASE_HOST, FACTORY_DATABASE_PORT, FACTORY_DATABASE_NAME, FACTORY_DATABASE_PASSWORD,
HOTEL_BACKUP_DATABASE_HOST, HOTEL_BACKUP_DATABASE_USERNAME, HOTEL_BACKUP_DATABASE_PASSWORD, HOTEL_DATABASE_HOST, HOTEL_DATABASE_PORT, HOTEL_DATABASE_NAME, HOTEL_DATABASE_PASSWORD

Did you spot the accidentally missed variable in the list above which caused the critical bug?

[StrictYAML](https://hitchdev.com/strictyaml) version:

```yaml
database:
  personnel:
    host: xxx
    port: xxx
    name: xxx
    password: xxx

  factory:
    host: xxx
    port: xxx
    name: xxx
    password: xxx

  hotel backup:
    host: xxx
    name: xxx
    password: xxx

  hotel:
    host: xxx
    name: xxx
    port: xxx
    password: xxx
```

What about now?
