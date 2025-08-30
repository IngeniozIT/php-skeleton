# PHP skeleton

> Bored of manually setting up your PHP projects ?  
> This is the solution !

## Table of contents

- [Description](#description)
- [Installation](#installation)
- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Scripts](#scripts)
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
- **Infrastructure**
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

PHP 8.4+ or Docker.

## Getting started

### 0. (if you are using docker)

Create the Docker container and start a shell inside it:

```bash
make cli
```

### 1. Install the dependencies

```bash
composer install
```

### 2. Run the tests

```bash
make test
```

### 3. Time to code

The previous steps went well ?

**You are now ready to start coding !**

## Scripts

The project comes with a few useful scripts to help you manage docker and run the various quality scripts.

You can list them by running

```bash
make help
```

## Customize your app

Make the project truly yours by doing the following:

- [ ] Update the `composer.json` with your project's information
- [ ] Update the `README.md` file to describe your project
- [ ] Update the `LICENSE` file with your favorite license
