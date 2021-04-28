#!/bin/sh -ex

TEST_DIR=$(dirname "$(realpath "$0")")
OUTPUT="${TEST_DIR}/output"
RESULT_FILE="${OUTPUT}/result.txt"

usage() {
    echo "Usage: $0 [-c <case>]" 1>&2
    exit 1
}

while getopts ":c:h" opt; do
    case "$opt" in
        c) CASE="${OPTARG}" ;;
        *) usage ;;
    esac
done

[ -z "${CASE}" ] && usage

. "${TEST_DIR}/../../lib/sh-test-lib"
create_out_dir "${OUTPUT}"
cd "${OUTPUT}"

# Run test.
LOG_FILE="${OUTPUT}/${CASE}.log"
XML_FILE="${OUTPUT}/${CASE}.xml"
"${CASE}".bin --gtest_output=xml:"${XML_FILE}" | tee "${LOG_FILE}"

[ -f "${XML_FILE}" ] || report_fail "${CASE}"

# Parse gest output.
sed '/Gtest xml output finished/q' "${LOG_FILE}" \
    | grep -E "\[ *(OK|FAILED) *\]" \
    | awk '{printf("%s %s\n",$4,$2)}' \
    | sed 's/OK/pass/; s/FAILED/fail/' >> "${RESULT_FILE}"
