#! /usr/bin/bash
FILE_TEMPLATE=$(
	cat <<EOF
# Description

Today I will be working on:
  -
EOF
)

function get_date() {
	local date_result="$(date +%4Y)/$(date +%m)/$(date +%d)"
	echo ${date_result}
}
function get_date_folder() {
	#It could be done different
	local date=$1
	local date_folder=$(awk 'BEGIN{FS="/";OFS="/"};{print $1,$2 }' <<<${date})
	echo ${date_folder}
}
function get_date_day() {
	local date=$1
	local date_day=$(awk 'BEGIN{FS="/"};{print $NF}' <<<${date})
	echo ${date_day}
}
# if year or month have not been created
function create_folder() {
	local folder=${1}
	mkdir -p ${folder}
}
function checkFolder() {
	local folder=$1
	if [[ -d ${folder} ]]; then
		return 0
	else
		return 1
	fi
}

function get_folder_prefix() {
	local folder_prefix=$(find $HOME/Documents -mindepth 1 -type d | grep -Pi "projects\/dayTracker$")
	echo ${folder_prefix}
}

function main() {
	(
		local folder_prefix=$(get_folder_prefix)
		cd ${folder_prefix}
		local date="$(get_date)"
		local date_folder="$(get_date_folder ${date})"
		if [[ ! $(checkFolder "${date_folder}") ]]; then
			$(create_folder "${date_folder}")
		fi
		cd "${date_folder}"
		local date_day="$(get_date_day "${date}")"
		echo "${FILE_TEMPLATE}" >>"${date_day}.md"
		if [[ "${EDITOR}" =~ "nvim" ]]; then
			${EDITOR} -O "${date_day}.md" "${folder_prefix}/README.md"
		else
			${EDITOR} "${date_day}.md"
		fi
		git add ${date_day}.md && git commit -m "Adding what is supposed to be done today" && git push
	)

}
main
