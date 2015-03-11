git reset --hard HEAD
git checkout master
cd tests/parser/demo/
make
git checkout gh-pages
git checkout master tests/parser/demo/bin