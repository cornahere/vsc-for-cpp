#!/usr/bin/bash
# compile.sh by Corna
# -*- coding: UTF-8 -*-

# parameters
File="$1"
NoExtname="$2"
Extname="$3"
Workspace="$4"

# constats
RED="\e[1;31m"	# Red
GRE="\e[1;32m"	# Green
BLU="\e[1;34m"	# Blue
RST="\e[0m"		# Reset color

log_path="$Workspace/.vscode/cache.log"
bin_path="$Workspace/bin/$NoExtname.out"
inc_path="$Workspace/inc"
src_path="$File"

check_hash() {
	log=($(grep "$src_path" "$log_path"))
	# log or binary not found -> return directly
	if [ $? -ne 0 ] || [ ! -e "$bin_path" ]
	then
		return 1
	fi

	bin_hash="${log[0]}"
	src_hash="${log[1]}"

	now_bin_hash_arr=($(cksum "$bin_path"))
	now_src_hash_arr=($(cksum "$src_path"))
	now_bin_hash=${now_bin_hash_arr[0]}
	now_src_hash=${now_src_hash_arr[0]}
	
	[ "$src_hash" = "$now_src_hash" ] && [ "$bin_hash" = "$now_bin_hash" ]
}

get_compiler() {
	case $Extname in
	".cpp")	printf "g++";;
	".c")	printf "gcc";;
	*)
		echo -e "${RED}[ERR] Unknown file type.${RST}" >&2
		exit 1
		;;
	esac
}

get_argument() {
	printf ' -D_DEBUG_=1 -W -Wall -ggdb -lm -O0'
	case $Extname in
	".cpp")	printf " -std=c++23";;
	".c")	printf " -std=c23";;
	esac
}

write_hash() {
	now_bin_hash_arr=($(cksum "$bin_path"))
	now_src_hash_arr=($(cksum "$src_path"))
	now_bin_hash=${now_bin_hash_arr[0]}
	now_src_hash=${now_src_hash_arr[0]}
	
	grep "$src_path" "$log_path" >/dev/null
	if [ $? -ne 0 ]
	then
		echo "$now_bin_hash $now_src_hash $src_path" >>"$log_path"
		return
	fi

	sed -i "s/$bin_hash/$now_bin_hash/" "$log_path"
	sed -i "s/$src_hash/$now_src_hash/" "$log_path"
}

main() {
	if check_hash
	then
		echo -e "${BLU}Source has already been built. Debug the binary directly.${RST}"
		exit
	fi

	get_compiler > /dev/null

	if ! $(get_compiler) "$src_path" -I "$inc_path" -o "$bin_path" $(get_argument)
	then
		echo -e "${RED}[ERR] Failed in building. Check the compilation log above for detail.${RST}"
		exit 1
	else
		write_hash
		echo -e "${GRE}Build succussfully.${RST}"
	fi
}

main