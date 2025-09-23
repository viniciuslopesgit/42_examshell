#!/bin/bash
source colors.sh

rank=$1
level=$2

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
subject_file="/tmp/.current_subject_${rank}_${level}"

get_subjects() {
    case "$level" in
        level1)
            echo "bigint polyset vect2"
            ;;
        level2)
            echo "bsq life"
            ;;
        *)
            echo ""
            ;;
    esac
}

subjects_list=$(get_subjects)
IFS=' ' read -r -a qsub <<< "$subjects_list"
count=${#qsub[@]}
random_index=$(( RANDOM % count ))
chosen="${qsub[$random_index]}"
echo "$chosen" > "$subject_file"

mkdir -p "$base_dir/../../rendu/$chosen"
touch "$base_dir/../../rendu/$chosen/$chosen.cpp"

# Copy the .hpp file from the question folder to rendu
if [ -f "$base_dir/../rank05/level1/$chosen/$chosen.hpp" ]; then
    cp "$base_dir/../rank05/level1/$chosen/$chosen.hpp" "$base_dir/../../rendu/$chosen/$chosen.hpp"
else
    touch "$base_dir/../../rendu/$chosen/$chosen.hpp"
fi

# If polyset is selected for rank05 level1, copy subject folder files
if [[ "$level" == "level1" && "$chosen" == "polyset" ]]; then
    src_subject_dir="$base_dir/../rank05/level1/polyset/subject"
    dest_dir="$base_dir/../../rendu/polyset"
    if [ -d "$src_subject_dir" ]; then
        mkdir -p "$dest_dir"
        cp "$src_subject_dir"/* "$dest_dir"/
    fi
fi

cd "$base_dir/../rank05/level1/$chosen" || {
    echo -e "${RED}Subject folder not found.${RESET}"
    exit 1
}

clear
echo -e "${CYAN}${BOLD}Your subject: $chosen${RESET}"
echo "=================================================="
cat sub.txt
echo
echo -e "=================================================="
echo -e "${YELLOW}Type 'test' to test your code, 'next' to get a new question, or 'exit' to quit.${RESET}"

while true; do
    read -rp "/> " input
    case "$input" in
        test)
            clear
            echo -e "${GREEN}Running tester.sh...${RESET}"
            output=$(./tester.sh 2>&1)
            echo "$output" | tee tester_output.log

            if echo "$output" | grep -q "PASSED"; then
                echo -e "${GREEN}${BOLD}✔️  Passed!${RESET}"
                rm -f "$subject_file"
                sleep 1
                exit 0
            else
                echo -e "${RED}${BOLD}❌  Failed.${RESET}"
                sleep 1
                exit 1
            fi
            ;;
        next)
            echo -e "${BLUE}🔄 Picking a new subject...${RESET}"
            subjects_list=$(get_subjects)
            IFS=' ' read -r -a qsub <<< "$subjects_list"
            count=${#qsub[@]}
            random_index=$(( RANDOM % count ))
            chosen="${qsub[$random_index]}"
            echo "$chosen" > "$subject_file"
            # Repeat setup for new subject
            mkdir -p "$base_dir/../../rendu/$chosen"
            touch "$base_dir/../../rendu/$chosen/$chosen.cpp"
            if [ -f "$base_dir/../rank05/level1/$chosen/$chosen.hpp" ]; then
                cp "$base_dir/../rank05/level1/$chosen/$chosen.hpp" "$base_dir/../../rendu/$chosen/$chosen.hpp"
            else
                touch "$base_dir/../../rendu/$chosen/$chosen.hpp"
            fi
            # If polyset is selected for rank05 level1, copy subject folder files
                if [[ "$rank" == "rank05" && "$level" == "level1" && "$chosen" == "polyset" ]]; then
                    src_subject_dir="$base_dir/../rank05/level1/polyset/subject"
                    dest_dir="$base_dir/../../rendu/polyset/subject"
                if [ -d "$src_subject_dir" ]; then
                    cp -r "$src_subject_dir" "$base_dir/../../rendu/polyset/"
                fi
            fi
            cd "$base_dir/../rank05/level1/$chosen" || {
                echo -e "${RED}Subject folder not found.${RESET}"
                exit 1
            }
            clear
            echo -e "${CYAN}${BOLD}Your subject: $chosen${RESET}"
            echo "=================================================="
            cat sub.txt
            echo
            echo -e "=================================================="
            echo -e "${YELLOW}Type 'test' to test your code, 'next' to get a new question, or 'exit' to quit.${RESET}"
            ;;
        exit)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Please type 'test' to test code, 'next' for next or 'exit' for exit."
            ;;
    esac
done
