# trurlploy
set of scripts for post-receive git hook fullfunctional deploy



# trurlploy.sh

put this file in BAREREPO.git/hooks/post-receive on production server (but not in production folder directly, of course).

You may add this to repo too, but this file will just removed during deploy.


# trurlploy-before.sh

Example for adding to repo.

Run in preproduction dir TEST_REPLOY_DIR before replacing real production.

Any errors on this stage will ABORT deploy process.

Running in realtime, so it's may be used only for small/middle projects.

# trurlploy-post.sh

Example for adding to repo.

Run in real production dir WORK_REPLOY_DIR.

For example for try to restart something if need (production server restart? huh...)

Or just inform about new build in production

