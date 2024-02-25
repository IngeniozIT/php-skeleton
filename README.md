# PHP skeleton

> Bored of manually setting up your PHP projects ?  
> This is the solution !

## Table of contents

- [Description](#description)
- [Installation](#installation)
- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Code quality](#code-quality)
- [Docker](#docker)
- [Customize your app](#customize-your-app)

## Description

This is a skeleton for PHP projects that focus on **code quality**.   
It contains pretty much everything you need to start a new project :

- **Code quality**
  - A working unit test (using [PHPUnit](https://github.com/sebastianbergmann/phpunit)) to bootstrap your coding experience
  - Static analyis tools ([phpcs](https://github.com/squizlabs/PHP_CodeSniffer), [phpstan](https://github.com/phpstan/phpstan), [psalm](https://github.com/vimeo/psalm), [phpmd](https://github.com/phpmd/phpmd) and [phan](https://github.com/phan/phan)) to enforce the quality of your code
  - A mutation testing framework ([Infection](https://github.com/infection/infection)) to enforce the quality of your tests
  - An automated refactoring tool ([Rector](https://github.com/rectorphp/rector)) to help you keep your code up to date
  - Composer scripts to easily use all the above
- **Infra**
  - Docker support
    - A Makefile to manage docker commands with ease
  - GitHub workflows to automatically run the tests and quality tools on every push and pull request
    - It also uploads a code coverage report to [CodeCov](https://codecov.io/)

## Installation

To create a new project based on this skeleton, run the following command:

```bash
composer create-project ingenioz-it/php-skeleton {PROJECT_NAME}
```

## Requirements

- docker
- make (optional)

OR

- PHP 8.2 or higher
- composer
- xdebug

## Getting started

I suggest you run the full set of tests to make sure everything is working correctly:

### 1. Move to your new project.

```bash
cd {PROJECT_NAME}
```

### 2. Setup the project

#### If you are using Docker

```bash
make build && make start && make cli
```

*This will build the Docker image and start a shell inside the container (use `exit` to go back to your local terminal).*

#### If you are NOT using Docker

```bash
composer install
```

### 3. Finally, run the tests

```bash
composer fulltest
```

The last line should be:

```
OK
```

**You are now ready to start coding !**

## Code quality

The project comes with a few useful composer scripts to help you work with it.

You can view their description inside the `composer.json` file (look for `scripts-descriptions`), but here is a quick overview of the main ones:

- `composer serve`: Runs a local web server on port 8000. Run this command and go to http://localhost:8000 to see the magic happen.
- `composer testdox`: Runs the unit tests using the `testdox` format (it's better looking than the default one).
- `composer coverage-html`: Generates a code coverage report in HTML format inside the `doc/` directory.
- `composer quality:infection`: Generates a mutation testing report in HTML format at `tmp/infection.html`.
- `composer quality:clean`: Runs phpcbf to automatically fix code formatting issues.
- `composer quality:refactor`: Runs Rector to automatically refactor your code. **Warning:** This is a very powerful tool that can break your code. Use `composer quality:refactor-dry` to preview the changes before applying them.
- `composer fulltest`: Runs the full set of tests (unit tests, static analysis tools and mutation testing).

## Docker

The project comes with a `Makefile` to help you manage your Docker container:

- `make build` : Builds the Docker image
- `make start` : Starts the Docker container (go to http://localhost:8080 to see your app live)
- `make stop` : Stops the Docker container
- `make restart` : Restarts the Docker container
- `make rebuild` : Rebuilds the Docker image and restarts the container
- `make remove` : Removes the Docker container
- `make cli` : Access a command line the container (useful to run the various composer scripts)
- `make logs` : Displays the logs of the Docker container
- `make clean` : Cleans the docker environment

## Customize your app

Make the project truly yours by doing the following:

- [ ] Update the `composer.json` with your project's information
- [ ] Update the `README.md` file to describe your project
- [ ] Update the `LICENSE` file with your favorite license
