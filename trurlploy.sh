#!/usr/bin/env sh
#
# (c) Trurl McByte
#
# put this file in BAREREPO.git/hooks/post-receive on prodaction server (but not in production folder directly, of course)
#
# files in repo:
# trurlploy.sh - just will be removed (just for store it to prevent loose)
#
# trurlploy-before.sh - run in preprodaction dir TEST_REPLOY_DIR before replacing real production
# any errors on this stage will ABORT deploy process with report
#
# trurlploy-post.sh - run in real production dir WORK_REPLOY_DIR
# for example for try to restart something if need (production server restart? huh...)
#
GIT_DIR=$(pwd)
P_DIR=$(dirname "${GIT_DIR}")
PROJECT_NAME=$(basename "${GIT_DIR}")
PROJECT_NAME="${PROJECT_NAME%.git}"
# default settins:
test "${TMP_DIR}" || TMP_DIR='/tmp'
# customize it to something like "~/not_a_public_html"
TEST_REPLOY_DIR="${P_DIR}/${PROJECT_NAME}_test"
# production folder here! (like "~/public_html", if you from php.net here)
WORK_REPLOY_DIR="${P_DIR}/${PROJECT_NAME}_work"
# tempporary old copy
OLD_REPLOY_DIR="${P_DIR}/${PROJECT_NAME}_old"
# select branch to deploy
DEPLOY_BRANCH="refs/heads/production"

LOCK_FILE="${TEST_REPLOY_DIR}.lock"
export GIT_DIR FROM_REV THIS_REV CURRENT_BRANCH DEPLOY_READY WORK_REPLOY_DIR TEST_REPLOY_DIR PROJECT_NAME lock_fd

DEPLOY_READY=-1
while read p_from p_to p_branch
do
    #echo "params P=${PROJECT_NAME} from=$p_from to=$p_to branch=$p_branch DEPLOY_READY=$(DEPLOY_READY)"
    FROM_REV="${p_from}"
    THIS_REV="${p_to}"
    CURRENT_BRANCH="${p_branch}"
    test "x_${CURRENT_BRANCH}" = "x_${DEPLOY_BRANCH}" && DEPLOY_READY="0"
done
#echo "o params P=${PROJECT_NAME} from=$FROM_REV to=$THIS_REV branch=$CURRENT_BRANCH DEPLOY_READY=$(DEPLOY_READY)"

# if need to deply?
test "x${DEPLOY_READY}" != "x0" && exit


DEPLOY_OUT="${TMP_DIR}/deploy.$$.txt"

reportit () {
  (
    echo "Deploy report ad $(date):";
    echo "Result: ${1}";
    test -r "${DEPLOY_OUT}" && cat "${DEPLOY_OUT}" && rm "${DEPLOY_OUT}";
    flock -u "$lock_fd"
    rm -f "${LOCK_FILE}"
  );
}

test -f "${LOCK_FILE}" && fuser "${LOCK_FILE}" && { echo "Deploy already running, abort (type 1)"; exit 1; }
exec {lock_fd}>"${LOCK_FILE}" || { echo "Deploy already running, abort (type 2)"; exit 1; }
flock -n "$lock_fd" || { echo "Deploy already running, abort (type 3)"; exit 1; }

#
rm -rf "${TEST_REPLOY_DIR}"
# or
#test -d "${TEST_REPLOY_DIR}" && reportit 'Abort! Test directory already exists!' && exit 2

mkdir -p "${TEST_REPLOY_DIR}"
/usr/bin/git archive "${CURRENT_BRANCH}" --format tar --worktree-attributes | tar -C "${TEST_REPLOY_DIR}" -xf -
pushd "${TEST_REPLOY_DIR}" &> /dev/null
touch ./trurlploy-before.sh
DEPLOY_READY=0
(
set -e
exec 2>&1
########## voodoo on
. ./trurlploy-before.sh
########## voodoo off
)
# or catch it to > "${DEPLOY_OUT}"
DEPLOY_READY=$?
rm -f trurlploy.sh trurlploy-before.sh
popd &> /dev/null

if test "x${DEPLOY_READY}" != "x0"; then
    rm -rf "${TEST_REPLOY_DIR}"
    reportit 'Voodoo failed!'
    exit 3
fi

test -d "${OLD_REPLOY_DIR}" && chmod -R +r "${OLD_REPLOY_DIR}" && rm -rf "${OLD_REPLOY_DIR}"
if test -d "${WORK_REPLOY_DIR}"; then
    # mv -T --backup=numbered "${TEST_REPLOY_DIR}" "${WORK_REPLOY_DIR}"
    # I'm kidding.. You may also copy some files from exists work dir to new here
   time (  mv -vT "${WORK_REPLOY_DIR}" "${OLD_REPLOY_DIR}" && mv -vT "${TEST_REPLOY_DIR}" "${WORK_REPLOY_DIR}" )
else
    mv -vT "${TEST_REPLOY_DIR}" "${WORK_REPLOY_DIR}"
fi

pushd "${WORK_REPLOY_DIR}" &> /dev/null
# if something need to do in work dir AFTER deploy
# failed command here NOT aborting anything (too late)
test -r ./trurlploy-post.sh && . ./trurlploy-post.sh
rm -f trurlploy-post.sh
#
popd &> /dev/null


test -d "${OLD_REPLOY_DIR}" && chmod -R +r "${OLD_REPLOY_DIR}" && rm -rf "${OLD_REPLOY_DIR}"
#or leave it for next time

git gc --auto
reportit 'All fine'
exit 0
#
