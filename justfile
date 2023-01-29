export github_actions := env_var_or_default('GITHUB_ACTIONS', '0')

@clean:
    rm -rf tmp

[private]
@clean_log file: clean
    mkdir -p build/logs
    rm -f build/logs/{{file}}

[private]
@clean_dir directory: clean
    mkdir -p build/{{directory}}
    rm -rf build/{{directory}}/*

phpunit testsuite='': (clean_log 'clover.xml') (clean_log 'junit.xml') (clean_dir 'coverage')
    #!/usr/bin/env bash
    if ! [ "{{testsuite}}" = "" ]; then
      args="--testsuite {{testsuite}}"
    else
      args=""
    fi
    phpunit -c tests/phpunit.xml $args

@phpcs standard='../lunr-coding-standard/Lunr': (clean_log 'checkstyle.xml')
    phpcs \
      -p \
      --report-full \
      --report-checkstyle=build/logs/checkstyle.xml \
      --standard={{standard}} \
      src

@phpcbf standard='../lunr-coding-standard/Lunr':
    phpcbf \
      -p \
      --standard={{standard}} \
      src

phpstan level='6':
    #!/usr/bin/env bash
    xdebug=$(php -r "echo extension_loaded('xdebug') ? '--xdebug' : '';")
    if [ "{{github_actions}}" = "1" ]; then
      github="--error-format=github"
    else
      github=""
    fi
    phpstan analyze src -l {{level}} -c tests/phpstan.neon.dist $xdebug $github

@phploc: (clean_log 'phploc.json')
    phploc --log-json build/logs/phploc.json --count-tests src

@phpcpd: (clean_log 'pmd-cpd.xml')
    phpcpd --log-pmd build/logs/pmd-cpd.xml src

@pdepend: (clean_log 'jdepend.xml') (clean_dir 'pdepend')
    pdepend \
      --jdepend-xml=build/logs/jdepend.xml \
      --jdepend-chart=build/pdepend/dependencies.svg \
      --overview-pyramid=build/pdepend/overview-pyramid.svg \
      src

dependencies type='dev':
    #!/usr/bin/env bash
    if [ "{{type}}" = "release" ]; then
      args="--no-dev"
    else
      args=""
    fi
    decomposer install $args

@setup type='dev': (dependencies type)
