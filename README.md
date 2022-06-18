# BioGBA

Gameboy Advance emulator written in the V Programming Language.

- BioGBA is being developed using strict TDD.
- The main goal is to achive correctness first.
- I am also trying this new language

## Building BioGBA

You will need the V compiler: https://vlang.io/ .
Installation should be super simple. Just clone the project, run make, and put the v compiler in your PATH.

To compile BioGBA just run:

```shell
$ v src
```

**Note**: Right now, the executable just prints a nice `Hello World`. Current work is focused on building the components using TDD, so no need for an entrypoint right now.

## Running Tests

As I mentioned, BioGBA is beeng developed using strict Test Driven Development. This means that tests are run all the time, so it should be easy and fast. Fortunetaly V has a simple framework for testing. To run the full test suite just run

```shell
$ v test src
```
