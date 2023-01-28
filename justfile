export github_actions := env_var_or_default('GITHUB_ACTIONS', '0')

clean:
    #!/usr/bin/env bash
    rm -rf build
    rm -rf tmp
    mkdir -p build/{coverage,logs}

phpunit testsuite='': clean
    #!/usr/bin/env bash
    if ! [ "{{testsuite}}" = "" ]; then
      args="--testsuite {{testsuite}}"
    else
      args=""
    fi
    phpunit -c tests/phpunit.xml $args

@phpcs standard='../lunr-coding-standard/Lunr': clean
    phpcs \
      -p \
      --report-full \
      --report-checkstyle=build/logs/checkstyle.xml \
      --standard={{standard}} \
      src

@phpcbf standard='../lunr-coding-standard/Lunr': clean
    phpcbf \
      -p \
      --standard={{standard}} \
      src

phpstan level='6': clean
    #!/usr/bin/env bash
    xdebug=$(php -r "echo extension_loaded('xdebug') ? '--xdebug' : '';")
    if [ "{{github_actions}}" = "1" ]; then
      github="--error-format=github"
    else
      github=""
    fi
    phpstan analyze src -l {{level}} -c tests/phpstan.neon.dist $xdebug $github

@phploc: clean
    phploc --log-json build/logs/phploc.json --count-tests src

@phpcpd: clean
    phpcpd --log-pmd build/logs/pmd-cpd.xml src

dependencies type='dev':
    #!/usr/bin/env bash
    if [ "{{type}}" = "release" ]; then
      args="--no-dev"
    else
      args=""
    fi
    decomposer install $args

@setup type='dev': (dependencies type)
