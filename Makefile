SOURCES := $(shell find source -name '*.d')
TARGET_OS := $(shell uname -s)

.DEFAULT_GOAL := docs
all: docs

lib/blend2d/CMakeLists.txt:
	unzip lib/blend2d-beta16.zip -d lib
lib/blend2d/build/libblend2d.a: lib/blend2d/CMakeLists.txt
	mkdir -p lib/blend2d/build && \
	cd lib/blend2d/build && \
	cmake .. -DBLEND2D_STATIC=true -DBLEND2D_NO_INSTALL=true && \
	cmake --build .
# @echo "Sanity check for static lib:"
# ld -Llib/blend2d/src -l glfw3
# rm -f a.out
# @echo "👍️"
blend2d: lib/blend2d/build/libblend2d.a
.PHONY: blend2d

docs/sitemap.xml: $(SOURCES)
	dub build -b ddox
	@echo "Performing cosmetic changes..."
	# Navigation Sidebar
	@sed -i -e "/<nav id=\"main-nav\">/r views/nav.html" -e "/<nav id=\"main-nav\">/d" `find docs -name '*.html'`
	# Page Titles
	@sed -i "s/<\/title>/ - Gooey<\/title>/" `find docs -name '*.html'`
	# Index
	@sed -i "s/API documentation/API Reference/g" docs/index.html
	@sed -i -e "/<h1>API Reference<\/h1>/r views/index.html" -e "/<h1>API Reference<\/h1>/d" docs/index.html
	# License Link
	@sed -i "s/(?<!alt=\")MIT License/<a href=\"https:\/\/opensource.org\/licenses\/MIT\">MIT License<\/a>/" `find docs -name '*.html'`
	# Footer
	@sed -i -e "/<p class=\"faint\">Generated using the DDOX documentation generator<\/p>/r views/footer.html" -e "/<p class=\"faint\">Generated using the DDOX documentation generator<\/p>/d" `find docs -name '*.html'`
	@echo Done

docs: docs/sitemap.xml
.PHONY: docs

clean: clean-docs
	rm -f bin/gooey-test-library
	rm -f $(EXAMPLES)
	rm -f -- *.lst
.PHONY: clean

clean-docs:
	rm -f docs.json
	rm -f docs/sitemap.xml docs/file_hashes.json
	rm -rf `find docs -name '*.html'`
.PHONY: clean-docs

