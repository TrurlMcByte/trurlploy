# trurlploy-before.sh
# preproduction voodoo here
# You may setup test ENV also here
# This is currently NOT a WORK_REPLOY_DIR, but will be on production next stage (if someone try to use hardcoded path in production)
# but WORK_REPLOY_DIR variable available in env, and TEST_REPLOY_DIR (current) too
# also FROM_REV THIS_REV CURRENT_BRANCH PROJECT_NAME
# ANY failed command here aborting deploy process with report
#####################################################################

# any error (for example "file not found") will abort deploy
#chmod -f 0400 .gitignore
# so check all carefully
#test -f .some_file_not_exists && chmod -f 0400 .some_file_not_exists

# making troubles
#echo '<?php }} ?>' > badfile.php
# and versioning
#echo "<?php echo '\$Id:${THIS_REV}\$'; ?>" > cur_version.php

# GIT_DIR not here, but set
#git log "${FROM_REV}..${THIS_REV}" > some_news_on_site.txt

# linting examples
#find . -type f -name '*.php' -maxdepth 1 -print0 | xargs -0 -l1 /usr/bin/php -ql
#find src -type f -name '*.php' -print0 | xargs -0 -l1 /usr/bin/php -ql
#find . -type d \( -path '*/tests' -o -path '*/vendor' \) -prune -o -type f -name '*.php' -print0 | xargs -0 -l1 /usr/bin/php -ql

# Copy from old work dir (with trick to prevernt fail)
#cp -aT "${WORK_REPLOY_DIR}/images" "${TEST_REPLOY_DIR}/images" | true
#cp -aT "${WORK_REPLOY_DIR}/my_secret_file" "${TEST_REPLOY_DIR}/my_secret_file" | true

# composte it!
#composer install --no-ansi --no-dev --no-interaction --no-progress --optimize-autoloader # --no-scripts
# or mb faster
#cp -aT "${WORK_REPLOY_DIR}/vendor" "${TEST_REPLOY_DIR}/vendor" | true
#composer update --no-ansi --no-dev --no-interaction --no-progress --optimize-autoloader # --no-scripts

# Remove unnessesary
#rm -rf tests
#rm composer.*

# done