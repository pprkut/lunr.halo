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
    if [ "{{github_actions}}" = "1" ]; then
      args="--log-junit=build/logs/junit.xml --coverage-clover=build/logs/clover.xml"
    else
      args=""
    fi
    if ! [ "{{testsuite}}" = "" ]; then
      args+="--testsuite {{testsuite}}"
    else
      args+=""
    fi
    phpunit -c tests/phpunit.xml $args

phpcs standard='../lunr-coding-standard/Lunr': (clean_log 'checkstyle.xml')
    #!/usr/bin/env bash
    if [ "{{github_actions}}" = "1" ]; then
      args="--report-checkstyle=build/logs/checkstyle.xml"
    else
      args=""
    fi
    phpcs \
      -p \
      --report-full \
      --standard={{standard}} \
      $args \
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
    #!/usr/bin/env bash
    if [ "{{github_actions}}" = "1" ]; then
      args="--log-json build/logs/phploc.json"
    else
      args=""
    fi
    phploc --count-tests $args src

@phpcpd: (clean_log 'pmd-cpd.xml')
    #!/usr/bin/env bash
    if [ "{{github_actions}}" = "1" ]; then
      args="--log-pmd build/logs/pmd-cpd.xml"
    else
      args=""
    fi
    phpcpd $args src

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
