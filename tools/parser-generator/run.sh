BASE_DIR=$PWD
{
	echo "${BRIGHT_WHITE}${BOLD}> Converting Grammar${RESET}"
	# convert grammar
	cd grammar-converter	&&
	./run.sh				&&
	cd $BASE_DIR			&&

	echo "${BRIGHT_WHITE}${BOLD}> Building Lemon${RESET}"
	#build lemon
	cd "lemon-json"	&&
	make			&&
	cd $BASE_DIR	&&

	echo "${BRIGHT_WHITE}${BOLD}> Generating JSON Tables${RESET}"
	#run lemon to generate parser tables
	GRAMMAR="$(find . -name "*.lemon" -maxdepth 1)"	&&
	./lemon-json/lemon -j $GRAMMAR

	echo "${BRIGHT_WHITE}${BOLD}> Generating Parser${RESET}"
	#build parser generator
	haxe build.hxml	&&
	neko bin/generator.n &&

	echo "${GREEN}${BOLD}Complete${RESET}"
}
