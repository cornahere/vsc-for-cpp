#!/bin/sh

# compile.sh by Corna
# Create time: 2021/11/09 21:38
# Compile C/C++ sources intelligently
# Coding: UTF-8

# Process arguments
File="$1"
NoExtname="$2"
Extname="$3"
Workspace="$4"

PastShasum=`grep "$File" "$Workspace/.vscode/sha256sum.log"`
NowShasum=`sha256sum "$File"`

function extract() {
	printf $1
}

if [ "$PastShasum" != "$NowShasum" ]
then

#	An ancient way to test if file is compiled successful.
#	It has been discarded now.
#
#	if [ "$PastShasum" != "" ]
#	then
#		LastShasum="`sha256sum "$Workspace/bin/$NoExtname.run"`"
#	fi

	case $Extname in
	".cpp")
		if ! g++ "$File" -o "$Workspace/bin/$NoExtname.run" -I "$Workspace/inc/" -D _DEBUG_=1 -std=c++23 -W -Wall -ggdb -lm -Wmaybe-uninitialized
		then
			echo -e "\033[31;1mError\033[0m: \033[31;1mFailed to compile.\033[0m"
			exit 1
		fi 
		;;
	".c")
		if ! gcc "$File" -o "$Workspace/bin/$NoExtname.run" -I "$Workspace/inc/" -D _DEBUG_=1 -std=c17 -W -Wall -ggdb -lm -Wmaybe-uninitialized
		then
			echo -e "\033[31;1mError\033[0m: \033[31;1mFailed to compile.\033[0m"
			exit 1
		fi
		;;
	*)
		echo -e "\033[31;1mError\033[0m: Unknown file type."
		exit 1
		;;
	esac

#	An ancient way to test if file is compiled successful.
#	It has been discarded now.
#
#	if ! test -e "$Workspace/bin/$NoExtname.run" || [ "$PastShasum" != "" -a "`sha256sum "$Workspace/bin/$NoExtname.run"`" == "$LastShasum" ]
#	then
#		echo -e "$0: \033[1;31mError: Failed to compile.\033[0m\nIf you think that you program is right, try to delete $NoExtname.run if it is exist, delete the hash info in sha256sum.log and try compiling again.\nExiting. . ."
#		exit 1
#	fi

	# Add sha256sum info into logs.
	if [ "`grep "$File" "$Workspace/.vscode/sha256sum.log"`" = "" ]
	then
		echo "`sha256sum "$File"`" >>"$Workspace/.vscode/sha256sum.log"
	else
		sed -i "s/`extract $PastShasum`/`extract $NowShasum`/" "$Workspace/.vscode/sha256sum.log"
	fi

	echo -e "$0: \033[1;32mCompile successfully. Start to debug...\033[0m"
else
	echo -e "$0: \033[1;32mSource has already been compiled. Start to debug compiled file...\033[0m"
fi
