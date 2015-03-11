# reset any changes
git reset --hard HEAD

# rebuild demo
git checkout master
cd tests/parser/demo/
make
cd ../../../

# copy demo files to this branch
git checkout gh-pages
git checkout master tests/parser/demo/bin