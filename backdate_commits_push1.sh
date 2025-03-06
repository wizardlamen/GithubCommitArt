#!/bin/bash
# This script creates a sine wave in GitHub's contribution graph
# Spanning March 3, 2024, to March 1, 2025, across 7 rows

# Configuration
FILE="activity.txt"           # File to modify for commits
BRANCH="main"                # Your GitHub branch
REMOTE_NAME="origin"
REMOTE_URL="git@github.com:wizardlamen/githubcommit.git"
START_DATE="2024-03-03"      # Start date (March 3, 2024)
DAYS=363                     # Days from March 3, 2024, to March 1, 2025
ROWS=7                       # GitHub graph has 7 rows (Sun-Sat)

# Check and add remote if not present
EXISTING_REMOTE=$(git remote | grep "$REMOTE_NAME")
if [ -z "$EXISTING_REMOTE" ]; then
    echo "Adding remote GitHub repository..."
    git remote add origin "$REMOTE_URL"
fi

# Create the file if it doesn't exist
if [ ! -f "$FILE" ]; then
    echo "Initializing activity log" > "$FILE"
fi

echo "Creating commits to draw a sine wave from March 3, 2024, to March 1, 2025..."

# Loop over days (columns)
for (( d=0; d<DAYS; d++ ))
do
    # Calculate the commit date (March 3, 2024 + d days)
    COMMIT_DATE=$(date -d "$START_DATE + $d days" +"%Y-%m-%dT12:00:00")

    # Loop over rows (0 = Sunday, 6 = Saturday)
    for (( r=0; r<ROWS; r++ ))
    do
        # Calculate sine wave height (0 to 6 for 7 rows)
        # Sine wave: amplitude = 3, centered at 3, period = 1 year (363 days)
        SINE_VALUE=$(echo "3 + 3 * s($d * 6.2832 / $DAYS)" | bc -l)
        HEIGHT=$(printf "%.0f" "$SINE_VALUE")  # Round to nearest integer (0-6)

        # Background commits (1-3) for all squares
        BACKGROUND_COMMITS=$(( (RANDOM % 3) + 1 ))
        for (( c=1; c<=BACKGROUND_COMMITS; c++ ))
        do
            echo "Background commit $c for $COMMIT_DATE row $r" >> "$FILE"
            git add "$FILE"
            GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                git commit -m "Background commit $c for $COMMIT_DATE row $r"
        done

        # Add sine wave commits (7+) when the row matches the sine height
        if [ "$r" -eq "$HEIGHT" ]; then
            for (( c=1; c<=7; c++ ))
            do
                echo "Sine wave commit $c for $COMMIT_DATE row $r" >> "$FILE"
                git add "$FILE"
                GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                    git commit -m "Sine wave commit $c for $COMMIT_DATE row $r"
            done
        fi
    done
done

echo "Finished: Created commits for sine wave pattern."

# Push to GitHub
echo "Pushing commits to GitHub remote repository..."
git push -u origin "$BRANCH"

echo "Push complete. Check your GitHub contribution graph!"
