#!/bin/bash
set -x

if [ ! -f .changie.yaml ];
then
  echo "changie init"
  changie init
  # require to format unreleased file with more accurate name than seconds to avoid overriding file during multiple `changie new` in same seconds
  echo "fragmentFileFormat: '{{.Kind}}-{{.Time.Format \"02012006-150405.000\"}}'" >> .changie.yaml
fi

noRelease=$(cat CHANGELOG.md | grep 'No releases yet')

# if never release take the first commit of all time
if [ -z "$noRelease" ];
then
  lastVersion=$(changie latest)
  lastSeenCommit=$(cat .changes/$lastVersion.md | grep --only-matching --max-count 1 -E '\b[0-9a-f]{5,40}\b')
else
  lastSeenCommit=$(git rev-list --max-parents=0 HEAD --abbrev-commit)
fi

commit=$(git log --oneline --pretty=format:'%h - %s' --abbrev-commit $lastSeenCommit..HEAD)

# deal with case of no new commit
if [ -n "$commit" ]; then

 # add all new commit as unreleased change
 while IFS= read -r line ; do
   echo "$line";
   changie new --kind Changed --body "$line"
 done <<< "$commit"

 # group unreleased change in version file
 changie batch auto | true

 # create changelog file
 changie merge
fi

