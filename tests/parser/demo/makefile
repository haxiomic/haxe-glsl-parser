BIN=bin
SOURCE=src
MAIN=Main
#js
OUTJS=js/main.js
HTML=templates/html

#build.hxml is generated because it can improve auto-completion 
BUILDHXML=	-js $(BIN)/$(OUTJS)\
			"\n"-main $(MAIN)\
			"\n"-cp $(SOURCE)\
			"\n"-cp ../../../\
			"\n"-D analyzer\

all: clean build.hxml output-directory copy-template
	haxe build.hxml
	@echo "Build Complete: "$(BIN)/$(OUTJS)

build.hxml:
	@echo $(BUILDHXML) > build.hxml

.PHONY: output-directory
output-directory:
	@mkdir -p $(BIN)

.PHONY: copy-template
copy-template: output-directory
	@cp -r $(HTML)/ $(BIN)/

.PHONY: run
run: all install-autoreload
	autoreload-server -f ".js" "./$(BIN)" 8080

.PHONY: install-autoreload
install-autoreload: npm-required
	@if ! hash autoreload-server 2>/dev/null; then \
		while [ -z "$$CONTINUE" ]; do \
				read -r -p "npm package autoreload-server is required, do you want to install [y/N]: " CONTINUE; \
		done ; \
		if [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ]; then \
			sudo npm install -g simple-autoreload-server; \
		else \
			exit 1; \
		fi \
	fi

.PHONY: npm-required
npm-required:
	@if ! hash npm 2>/dev/null; then \
		echo "npm is required to install autoreload-server"; \
		exit 1; \
	fi

.PHONY: clean
clean:
	@rm -rf $(BIN)
	@rm -f build.hxml 