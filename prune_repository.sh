#! /usr/bin/bash

BACKUPDIR="./backup"
BACKUP_LOCATION_GIT="$BACKUPDIR/$(date -Idate)"
BACKUP_LOCATION_INDEX="$BACKUPDIR/index_$(date -Idate).html"

if [ -n "$(git status --porcelain)" ]; then
    echo
    echo "Found uncommitted changes."
    echo

    exit 1
fi

if [ -d "$BACKUP_LOCATION_GIT" ]; then
    echo
    echo "Output directory \"$BACKUP_LOCATION_GIT\" already exists."
    echo

    exit 1
else
    mkdir -p "$BACKUP_LOCATION_GIT"
fi

echo
echo "Pulling latest changes from remote repository ..."
echo

if ! git pull; then
    echo
    echo "Git pull returned a non-zero exit code."
    echo

    exit 1
fi

echo
echo "Backup local repository ..."
echo

mv ".git" "$BACKUP_LOCATION_GIT"
cp "index.html" "$BACKUP_LOCATION_GIT/index.html"
cp "index.html" "$BACKUP_LOCATION_INDEX"

echo
echo "Create new local repository ..."
echo

git init
git status

git config --local credential.helper ''
git config --local commit.gpgsign false
git config --local user.name "May Bee"
git config --local user.email "may.bee@123.plirp"

echo
echo "Add relevant files ..."
echo

git add .
git add -f index.html
git status

echo
echo "Create single commit from current data ..."
echo

git commit -m "new root commit"
git log

echo
echo "Upload to remote repository ..."
echo

git remote add origin https://github.com/mzuther/devnotes.git
git push --force --set-upstream origin main

echo
echo "Done."
echo
