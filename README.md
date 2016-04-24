# crystal-edge

A set of Rake tasks to build an edge (pre-released) version of Crystal.

## NO GUARANTEE

There is no guarantee of anything.

## Required Environments

* Crystal (latest, released)
* Libraries for building Crystal (see https://github.com/crystal-lang/crystal/wiki/All-required-libraries)
* Make
* Rake

## Usage

### Build

1. Clone this repo with its submodules.

  ```bash
  $ git clone --recursive https://github.com/mosop/crystal-edge.git /path/to/edge
  ```

1. cd & rake!

  ```bash
  $ cd /path/to/edge
  $ rake build:release
  ```

### Install (crenv)

```bash
$ rake crenv:install
```

This makes a symlink into your crenv's versions directory. The version's name is "edge".

## License

No license. PUBLIC DOMAIN :)
