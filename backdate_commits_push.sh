#!/bin/bash
# This script creates a series of commits with backdated timestamps
# and then pushes them to your GitHub repository.
#
# IMPORTANT:
# Make sure that your repository is already initialized (git init) and that
# you have added the remote repository pointing to GitHub using Git SSH.
# SSH Remote URL: git@github.com:wizardlamen/githubcommit.git

# Configuration: Adjust these variables as needed
# Number of days in the past to start from
START_DAYS_AGO=30
# Total number of commits to create
TOTAL_COMMITS=30
# The file that will be modified by each commit
FILE="activity.txt"
# Your GitHub branch (main or master, adjust accordingly)
BRANCH="master"

# Check if the remote is already added; if not, add it.
REMOTE_NAME="origin"
EXISTING_REMOTE=$(git remote | grep "$REMOTE_NAME")
if [ -z "$EXISTING_REMOTE" ]; then
    echo "Adding remote GitHub repository..."
    git remote add origin git@github.com:wizardlamen/githubcommit.git
fi

# Create the file if it doesn't exist
if [ ! -f "$FILE" ]; then
    echo "Initializing activity log" > "$FILE"
fi

echo "Creating $TOTAL_COMMITS commits starting from $START_DAYS_AGO days ago..."

# Loop to create each commit
for (( i=0; i<TOTAL_COMMITS; i++ ))
do
    # Calculate commit date: each commit spaced one day apart.
    COMMIT_DATE=$(date -d "$START_DAYS_AGO days ago + $i days" +"%Y-%m-%dT12:00:00")

    # Append a new line to the file
    echo "Commit number $((i+1)) on $COMMIT_DATE" >> "$FILE"

    # Stage the changes
    git add "$FILE"

    # Commit with the backdated timestamp using environment variables
    GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
        git commit -m "Commit number $((i+1)) on $COMMIT_DATE"
done

echo "Finished: Created $TOTAL_COMMITS backdated commits."

# Optionally, push your commits to GitHub
echo "Pushing commits to GitHub remote repository..."
git push -u origin "$BRANCH"

echo "Push complete. Your commit history is now updated on GitHub."
