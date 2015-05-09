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

	echo "${BRIGHT_WHITE}${BOLD}> Copying output to main glsl parser${RESET}"

	cp ./output/Tables.hx ../../glsl/parse/Tables.hx &&
	cp ./output/Actions.hx ../../glsl/parse/Actions.hx &&
	cp ./output/Parser.hx ../../glsl/parse/Parser.hx &&
	
	echo "${BRIGHT_WHITE}${BOLD}> Rebuilding demo${RESET}"
	#rebuild demo (temporary)
	cd ../../tests/demo
	make
	cd $BASE_DIR

	echo "${GREEN}${BOLD}Complete${RESET}"
}
