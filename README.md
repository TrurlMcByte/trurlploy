# trurlploy
set of scripts for post-receive git hook fullfunctional deploy



# trurlploy.sh 

put this file in BAREREPO.git/hooks/post-receive on prodaction server (but not in production folder directly, of course)

# trurlploy-before.sh

Run in preprodaction dir TEST_REPLOY_DIR before replacing real production.
Any errors on this stage will ABORT deploy process.

Running in realtime, so it's may be used only for small/middle projects.

# trurlploy-post.sh

Run in real production dir WORK_REPLOY_DIR
for example for try to restart something if need (production server restart? huh...)
or just inform about new build in production

