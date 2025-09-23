#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Comprehensive Test Script for bsq
echo -e "${BLUE}🔍 Running COMPREHENSIVE TESTING for bsq${NC}"
echo "=========================================="
echo ""

# Compile the reference solution
echo -e "${BLUE}📦 Compiling reference solution...${NC}"
gcc -Wall -Wextra -Werror -std=c99 -o ref_bsq main.c bsq.c

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Reference compilation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Reference compilation successful!${NC}"
echo ""

# Check if user solution files exist
USER_C_FILES=$(find ../../../../rendu/bsq/ -name "*.c" 2>/dev/null)
USER_H_FILES=$(find ../../../../rendu/bsq/ -name "*.h" 2>/dev/null)

if [ -z "$USER_C_FILES" ] || [ -z "$USER_H_FILES" ]; then
    echo -e "${RED}❌ User solution not found: No .c or .h files in ../../../../rendu/bsq/${NC}"
    exit 1
fi

# Copy and compile user solution
echo -e "${BLUE}📦 Compiling user solution...${NC}"
cp main.c user_main.c
cp -r ../../../../rendu/bsq/* .
gcc -Wall -Wextra -Werror -std=c99 -o user_bsq *.c
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ User compilation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ User compilation successful!${NC}"
echo ""

# Create test case files if they don't exist
if [ ! -f "test1.map" ]; then
    cat > test1.map << 'EOF'
9 . o x
...........................
....o......................
............o..............
...........................
....o......................
...............o...........
...........................
......o..............o.....
..o.......o................
EOF
fi

if [ ! -f "test2.map" ]; then
    cat > test2.map << 'EOF'
5 . # O
.....
.....
.....
.....
.....
EOF
fi

if [ ! -f "test3.map" ]; then
    cat > test3.map << 'EOF'
3 a b c
aaa
aaa
aaa
EOF
fi

# Test 1: Basic test with provided example
echo -e "${BLUE}🚀 Running Test 1: Basic example...${NC}"
./ref_bsq test1.map > ref_output1.txt 2>&1
echo "[DEBUG] Reference output for test1.map:"; cat ref_output1.txt
./user_bsq test1.map > user_output1.txt 2>&1
echo "[DEBUG] User output for test1.map:"; cat user_output1.txt

test1_match=true
if diff -q ref_output1.txt user_output1.txt > /dev/null; then
    echo -e "${GREEN}✅ Test 1 output matches reference!${NC}"
else
    echo -e "${RED}❌ Test 1 output does NOT match reference!${NC}"
    echo -e "${YELLOW}--- Reference Output ---${NC}"
    cat ref_output1.txt
    echo -e "${YELLOW}--- Your Output ---${NC}"
    cat user_output1.txt
    echo -e "${YELLOW}--- Diff ---${NC}"
    diff ref_output1.txt user_output1.txt
    test1_match=false
fi

# Test 2: Empty map test
echo -e "${BLUE}🚀 Running Test 2: Empty map...${NC}"
./ref_bsq test2.map > ref_output2.txt 2>&1
echo "[DEBUG] Reference output for test2.map:"; cat ref_output2.txt
./user_bsq test2.map > user_output2.txt 2>&1
echo "[DEBUG] User output for test2.map:"; cat user_output2.txt

test2_match=true
if diff -q ref_output2.txt user_output2.txt > /dev/null; then
    echo -e "${GREEN}✅ Test 2 output matches reference!${NC}"
else
    echo -e "${RED}❌ Test 2 output does NOT match reference!${NC}"
    test2_match=false
fi

# Test 3: Different characters test
echo -e "${BLUE}🚀 Running Test 3: Different characters...${NC}"
./ref_bsq test3.map > ref_output3.txt 2>&1
echo "[DEBUG] Reference output for test3.map:"; cat ref_output3.txt
./user_bsq test3.map > user_output3.txt 2>&1
echo "[DEBUG] User output for test3.map:"; cat user_output3.txt

test3_match=true
if diff -q ref_output3.txt user_output3.txt > /dev/null; then
    echo -e "${GREEN}✅ Test 3 output matches reference!${NC}"
else
    echo -e "${RED}❌ Test 3 output does NOT match reference!${NC}"
    test3_match=false
fi

# Test 4: Standard input test
echo -e "${BLUE}🚀 Running Test 4: Standard input...${NC}"
./ref_bsq < test1.map > ref_output4.txt 2>&1
echo "[DEBUG] Reference output for stdin:"; cat ref_output4.txt
./user_bsq < test1.map > user_output4.txt 2>&1
echo "[DEBUG] User output for stdin:"; cat user_output4.txt

test4_match=true
if diff -q ref_output4.txt user_output4.txt > /dev/null; then
    echo -e "${GREEN}✅ Test 4 (stdin) output matches reference!${NC}"
else
    echo -e "${RED}❌ Test 4 (stdin) output does NOT match reference!${NC}"
    test4_match=false
fi

# Run with valgrind for memory leak checking
echo -e "${BLUE}🚀 Executing valgrind analysis...${NC}"
echo "Command: valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes -s ./user_bsq test1.map"
echo ""

# Capture valgrind output to analyze
valgrind_output=$(valgrind \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    -s \
    --error-exitcode=1 \
    ./user_bsq test1.map 2>&1)

exit_code=$?

# Display the full output
echo "$valgrind_output"

echo ""
echo -e "${BLUE}🏁 Valgrind analysis completed with exit code: $exit_code${NC}"
echo ""

# Parse and analyze the output
echo "======================================="
echo -e "${YELLOW}📊 DETAILED ANALYSIS RESULTS:${NC}"
echo "======================================="

# Check for memory leaks
has_leaks=false
if echo "$valgrind_output" | grep -q "definitely lost:" && echo "$valgrind_output" | grep "definitely lost:" | grep -v "0 bytes"; then
    has_leaks=true
fi
if echo "$valgrind_output" | grep -q "indirectly lost:" && echo "$valgrind_output" | grep "indirectly lost:" | grep -v "0 bytes"; then
    has_leaks=true
fi
if echo "$valgrind_output" | grep -q "possibly lost:" && echo "$valgrind_output" | grep "possibly lost:" | grep -v "0 bytes"; then
    has_leaks=true
fi

# Check for errors
has_errors=false
if echo "$valgrind_output" | grep -q "ERROR SUMMARY" && echo "$valgrind_output" | grep "ERROR SUMMARY" | grep -v "0 errors"; then
    has_errors=true
fi

# Display results with color coding
echo -n "Test 1 (Basic example): "
if [ "$test1_match" = true ]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "Test 2 (Empty map): "
if [ "$test2_match" = true ]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "Test 3 (Different chars): "
if [ "$test3_match" = true ]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "Test 4 (Standard input): "
if [ "$test4_match" = true ]; then
    echo -e "${GREEN}PASSED${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "Memory Leaks: "
if [ "$has_leaks" = true ]; then
    echo -e "${RED}DETECTED - You have memory leaks!${NC}"
else
    echo -e "${GREEN}PASSED - No memory leaks detected${NC}"
fi

echo -n "Valgrind Errors: "
if [ "$has_errors" = true ]; then
    echo -e "${RED}DETECTED - Valgrind found errors!${NC}"
else
    echo -e "${GREEN}PASSED - No valgrind errors${NC}"
fi

echo ""
echo "======================================="
echo -n "OVERALL RESULT: "
all_tests_passed=true
if [ "$test1_match" = false ] || [ "$test2_match" = false ] || [ "$test3_match" = false ] || [ "$test4_match" = false ] || [ "$has_leaks" = true ] || [ "$has_errors" = true ]; then
    all_tests_passed=false
fi

if [ "$all_tests_passed" = true ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}Your bsq implementation is clean!${NC}"
else
    echo -e "${RED}❌ ISSUES DETECTED!${NC}"
    echo -e "${YELLOW}Summary of errors:${NC}"
    if [ "$test1_match" = false ]; then
        echo -e "${RED}  → Test 1 (Basic example) failed.${NC}"
    fi
    if [ "$test2_match" = false ]; then
        echo -e "${RED}  → Test 2 (Empty map) failed.${NC}"
    fi
    if [ "$test3_match" = false ]; then
        echo -e "${RED}  → Test 3 (Different chars) failed.${NC}"
    fi
    if [ "$test4_match" = false ]; then
        echo -e "${RED}  → Test 4 (Standard input) failed.${NC}"
    fi
    if [ "$has_leaks" = true ]; then
        echo -e "${RED}  → Memory leaks detected.${NC}"
    fi
    if [ "$has_errors" = true ]; then
        echo -e "${RED}  → Valgrind errors detected.${NC}"
    fi
fi
echo "======================================="

# Wait for user to press enter before continuing
read -rp "Press enter to continue..." dummy

# Cleanup temporary files
rm -f ref_bsq user_bsq user_main.c *.h *.c test1.map test2.map test3.map ref_output*.txt user_output*.txt
# Don't remove original files from user's rendu folder