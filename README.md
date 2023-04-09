# PHP skeleton

> Bored of manually setting up your PHP projects ?  
> This is the solution !

This is a skeleton for PHP projects that focus on **code quality**.   
It contains pretty much everything you need to start a new project :

- [x] A working unit test (using [PHPUnit](https://github.com/sebastianbergmann/phpunit)) to bootstrap your coding experience
- [x] Static analyis tools ([phpcs](https://github.com/squizlabs/PHP_CodeSniffer), [phpstan](https://github.com/phpstan/phpstan), [psalm](https://github.com/vimeo/psalm), [phpmd](https://github.com/phpmd/phpmd) and [phan](https://github.com/phan/phan)) to enforce the quality of your code
- [x] A mutation testing framework ([Infection](https://github.com/infection/infection)) to enforce the quality of your tests
- [x] Composer scripts to easily use all the above
- [x] GitHub workflows to automatically run the tests and quality tools on every push and pull request
  - [x] It also uploads a code coverage report to [CodeCov](https://codecov.io/)

## Requirements

- PHP 8.2 or higher
- [Composer](https://getcomposer.org/)
- [Xdebug](https://xdebug.org/)

## Installation

To create a new project based on this skeleton, run the following command (replace `{INSTALLATION_DIRECTORY}` with the directory where you want to install the project) :

```bash
composer create-project ingenioz-it/php-skeleton {INSTALLATION_DIRECTORY}
```

## Make sure everything works

Run the full set of tests to make sure everything has been installed correctly:

```bash
cd {INSTALLATION_DIRECTORY}
```

```bash
composer fulltest
```

The last line of the output should be:

```
OK
```

**You are now ready to start !**

## Then you might want to

Make the project truly yours by doing the following:

### Inside `composer.json`
- [ ] Update the `name`, `description`, `authors` and `license` fields with your project's information
- [ ] Update the `autoload` field with the namespace of your choice (make sure you also change the namespace in `src/HelloWorld.php` and `tests/FirstTest.php` accordingly)

### Inside other files
- [ ] Update the `README.md` file to decribe your project
- [ ] Update the `LICENSE` file with your favorite license

## Composer scripts

This skeleton comes with a few useful composer scripts to help you work with it.

You can view their description inside the `composer.json` file (look for `scripts-descriptions`), but here is a quick overview of the main ones:

```bash
composer serve
```

Runs a local web server on port 8000 with `index.php` as the entry point.  
Run this command and go to http://localhost:8000 to see the magic happen.

```bash
composer testdox
```
Runs the unit tests using the `testdox` format (it's better looking than the default one).

```bash
composer coverage-html
```

Generates a code coverage report in HTML format inside the `doc/` directory.

```bash
composer quality:infection
```

Generates a mutation testing report in HTML format at `tmp/infection.html`.

```bash
composer fulltest
```

Runs the full set of tests (unit tests, static analysis tools and mutation testing).

```bash
composer quality:clean
```

Runs phpcbf to automatically fix code formatting issues.

## Technical details

- The configuration files for the quality tools are located inside the `quality/` directory.
- The GitHub workflows are located inside the `.github/workflows/` directory.
