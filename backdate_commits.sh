#!/bin/bash
# This script creates various patterns in GitHub's contribution graph
# User chooses pattern, dates, and GitHub info

# Default file to modify
FILE="activity.txt"
ROWS=7  # GitHub graph rows (Sun-Sat)

# Function to calculate days between two dates
calculate_days() {
    START_DATE=$1
    END_DATE=$2
    START_SEC=$(date -d "$START_DATE" +%s)
    END_SEC=$(date -d "$END_DATE" +%s)
    DAYS=$(( (END_SEC - START_SEC) / 86400 + 1 ))  # +1 to include end date
    if [ $DAYS -lt 1 ]; then
        echo "Error: End date must be after start date."
        exit 1
    fi
    echo $DAYS
}

# Prompt user for GitHub info
echo "Enter your GitHub SSH remote URL (e.g., git@github.com:username/repo.git):"
read REMOTE_URL
echo "Enter your branch name (e.g., main):"
read BRANCH

# Check and add remote
REMOTE_NAME="origin"
EXISTING_REMOTE=$(git remote | grep "$REMOTE_NAME")
if [ -z "$EXISTING_REMOTE" ]; then
    echo "Adding remote GitHub repository..."
    git remote add origin "$REMOTE_URL"
else
    git remote set-url origin "$REMOTE_URL"
fi

# Prompt for dates
echo "Enter start date (YYYY-MM-DD, e.g., 2024-03-03):"
read START_DATE
echo "Enter end date (YYYY-MM-DD, e.g., 2025-03-01):"
read END_DATE

# Calculate number of days
DAYS=$(calculate_days "$START_DATE" "$END_DATE")
echo "Pattern will span $DAYS days from $START_DATE to $END_DATE."

# Prompt for pattern choice
echo "Choose a pattern to draw in your contribution graph:"
echo "1) Sine Wave"
echo "2) Cosine Wave"
echo "3) Cellular Automata (Rule 30)"
echo "4) Gaussian Curve"
read -p "Enter the number of your choice (1-4): " CHOICE

# Create file if it doesn’t exist
if [ ! -f "$FILE" ]; then
    echo "Initializing activity log" > "$FILE"
fi

echo "Creating commits for your chosen pattern..."

# Loop over days
for (( d=0; d<DAYS; d++ ))
do
    COMMIT_DATE=$(TZ=UTC date -d "$START_DATE + $d days" +"%Y-%m-%dT12:00:00+00:00")

    for (( r=0; r<ROWS; r++ ))
    do
        # Background commits (1-3)
        BACKGROUND_COMMITS=$(( (RANDOM % 3) + 1 ))
        for (( c=1; c<=BACKGROUND_COMMITS; c++ ))
        do
            echo "Background commit $c for $COMMIT_DATE row $r" >> "$FILE"
            git add "$FILE"
            GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                git commit -m "Background commit $c for $COMMIT_DATE row $r"
        done

        # Pattern-specific commits
        case $CHOICE in
            1) # Sine Wave
                SINE_VALUE=$(echo "3 + 3 * s($d * 6.2832 / $DAYS)" | bc -l)
                HEIGHT=$(printf "%.0f" "$SINE_VALUE")
                if [ "$r" -eq "$HEIGHT" ]; then
                    for (( c=1; c<=7; c++ ))
                    do
                        echo "Sine commit $c for $COMMIT_DATE row $r" >> "$FILE"
                        git add "$FILE"
                        GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                            git commit -m "Sine commit $c for $COMMIT_DATE row $r"
                    done
                fi
                ;;
            2) # Cosine Wave
                COS_VALUE=$(echo "3 + 3 * c($d * 6.2832 / $DAYS)" | bc -l)
                HEIGHT=$(printf "%.0f" "$COS_VALUE")
                if [ "$r" -eq "$HEIGHT" ]; then
                    for (( c=1; c<=7; c++ ))
                    do
                        echo "Cosine commit $c for $COMMIT_DATE row $r" >> "$FILE"
                        git add "$FILE"
                        GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                            git commit -m "Cosine commit $c for $COMMIT_DATE row $r"
                    done
                fi
                ;;
            3) # Cellular Automata (Rule 30)
                # Seed on day 0, middle row
                if [ $d -eq 0 ]; then
                    if [ $r -eq 3 ]; then
                        for (( c=1; c<=7; c++ ))
                        do
                            echo "CA seed commit $c for $COMMIT_DATE row $r" >> "$FILE"
                            git add "$FILE"
                            GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                                git commit -m "CA seed commit $c for $COMMIT_DATE row $r"
                        done
                    fi
                else
                    # Rule 30: left XOR (center OR right)
                    PREV_DAY=$(TZ=UTC date -d "$START_DATE + $((d-1)) days" +"%Y-%m-%dT12:00:00+00:00")
                    # Check previous day's state for left, center, right
                    if [ $r -gt 0 ]; then
                        LEFT=$(git log --oneline --after="$PREV_DAY" --before="$PREV_DAY" | grep "row $((r-1))" | grep "CA commit" | wc -l)
                        LEFT=$((LEFT > 0 ? 1 : 0))
                    else
                        LEFT=0
                    fi
                    CENTER=$(git log --oneline --after="$PREV_DAY" --before="$PREV_DAY" | grep "row $r" | grep "CA commit" | wc -l)
                    CENTER=$((CENTER > 0 ? 1 : 0))
                    if [ $r -lt 6 ]; then
                        RIGHT=$(git log --oneline --after="$PREV_DAY" --before="$PREV_DAY" | grep "row $((r+1))" | grep "CA commit" | wc -l)
                        RIGHT=$((RIGHT > 0 ? 1 : 0))
                    else
                        RIGHT=0
                    fi
                    # Apply Rule 30
                    NEW_STATE=$((LEFT ^ (CENTER || RIGHT)))
                    if [ "$NEW_STATE" -eq 1 ]; then
                        for (( c=1; c<=7; c++ ))
                        do
                            echo "CA commit $c for $COMMIT_DATE row $r" >> "$FILE"
                            git add "$FILE"
                            GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                                git commit -m "CA commit $c for $COMMIT_DATE row $r"
                        done
                    fi
                fi
                ;;
            4) # Gaussian Curve
                MIDPOINT=$(echo "$DAYS / 2" | bc)
                SIGMA=$(echo "$DAYS / 6" | bc -l)
                GAUSS_VALUE=$(echo "6 * e(-(($d - $MIDPOINT)^2)/(2 * $SIGMA^2))" | bc -l)
                HEIGHT=$(printf "%.0f" "$GAUSS_VALUE")
                if [ "$r" -le "$HEIGHT" ]; then
                    for (( c=1; c<=7; c++ ))
                    do
                        echo "Gaussian commit $c for $COMMIT_DATE row $r" >> "$FILE"
                        git add "$FILE"
                        GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" \
                            git commit -m "Gaussian commit $c for $COMMIT_DATE row $r"
                    done
                fi
                ;;
            *)
                echo "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    done
done

echo "Finished: Created commits for your pattern."

# Push to GitHub
echo "Pushing commits to GitHub remote repository..."
git push -u origin "$BRANCH"

echo "Push complete. Check your GitHub contribution graph!"
