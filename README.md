# crystal-edge

A set of Rake tasks for building edge (pre-released) versions of Crystal.

## Supported Platforms

* OS X (tested on Yosemite)
* Ubuntu (tested on 14.04)

NOTE: It should works on some other Linux distributions but not tested.

## Required Environments

* Crystal (latest, released) (see https://crystal-lang.org/docs/installation/)
* Installed Libraries (see https://github.com/crystal-lang/crystal/wiki/All-required-libraries)
* Git
* Make
* Rake

## Usage

### Build

Clone this repository,

```sh
$ git clone https://github.com/mosop/crystal-edge.git /path/to/crystal-edge
```

and rake!

```sh
$ cd /path/to/crystal-edge
$ rake build
```

#### Specifying a Branch or Tag

```sh
$ CRYSTAL_EDGE_REF=0.20.5 rake build
```

### Install (crenv)

After you build, do:

```sh
$ rake crenv:install
```

This makes a symlink into your crenv's versions directory. The default version's name is "edge".

You can specify the name.

```sh
$ CRYSTAL_EDGE_VERSION_NAME=early rake crenv:install
```

### Clean

See the versions directory (/path/to/crystal-edge/versions) and just remove underlying directories that you no longer need.

## License

No license. PUBLIC DOMAIN :)
