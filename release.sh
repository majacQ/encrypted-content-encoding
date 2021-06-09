#!/usr/bin/env bash

set -e

root=$(cd $(dirname "$0"); pwd -P)
cd "$root"
sub='{ s/^.*["'"'"']\([0-9]*\.[0-9]*\.[0-9]*\)["'"'"'].*$/\1/;p; }'
old1=$(sed -n -e '/version *=/'"$sub"'' python/setup.py)
old2=$(sed -n -e '/"version" *:/'"$sub"'' nodejs/package.json)

if [ "$old1" != "$old2" ]; then
    echo "Versions aren't the same: $old1 != $old2" 1>&2
    exit 1
fi
IFS=. v=($old1)
new="${v[0]}.${v[1]}.$((${v[2]} + 1))"

sub='s/\(["'"'"']\)'"$old1"'["'"'"']/\1'"$new"'\1/'
sed -i~ -e '/version *=/'"$sub" python/setup.py
sed -i~ -e '/"version" *:/'"$sub" nodejs/package.json

cd "$root"/python
python setup.py sdist
twine upload dist/http_ece-"$new".tar.gz

cd "$root"/nodejs
npm publish

git commit -m "Update version to $new" python/setup.py nodejs/package.json
git tag v"$new"
