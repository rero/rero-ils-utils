Q=@

# Source directory (CSS files and images)
SRC_DIR = ils
SRC_CSS = $(SRC_DIR)/css
SRC_IMG = $(SRC_DIR)/images

# Source files
CSS_FILES := $(wildcard ils/css/*.css)
IMG_FILES := $(wildcard ils/images/*.svg)

# Those we want to keep (some on /test directory, other on /pilot)
TEST_ORGS = global aoste fictive highlands
PILOT_ORGS = global bulle mvs rbnj

# Different destination directories
TEST_DIR = static/test
PILOT_DIR = static/pilot
O9_DIR = static-o9

# Destination files
TEST_CSS_FILES = $(TEST_ORGS:%=$(TEST_DIR)/css/%.css)
TEST_IMG_FILES = $(TEST_ORGS:%=$(TEST_DIR)/images/logo-%.svg)
PILOT_CSS_FILES = $(PILOT_ORGS:%=$(PILOT_DIR)/css/%.css)
PILOT_IMG_FILES = $(PILOT_ORGS:%=$(PILOT_DIR)/images/logo-%.svg)
O9_CSS_FILES = $(CSS_FILES:%=$(O9_DIR)/%)
O9_IMG_FILES = $(IMG_FILES:%=$(O9_DIR)/%)

# What will be generated
all: static.tar.gz static-o9.tar.gz


# ils/test files
$(TEST_DIR)/css : $(TEST_CSS_FILES)
	$Qmkdir -p $(@D)

$(TEST_DIR)/css/%.css : $(SRC_CSS)/%.css
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"
	$Qsed -i 's#resources\.rero\.ch/ils#resources\.rero\.ch/ils/test#g' "$@"

$(TEST_DIR)/images : $(TEST_IMG_FILES)
	$Qmkdir -p $(@D)

$(TEST_DIR)/images/logo-%.svg : $(SRC_IMG)/logo-%.svg
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"


# ils/pilot files
$(PILOT_DIR)/css : $(PILOT_CSS_FILES)
	$Qmkdir -p $(@D)

$(PILOT_DIR)/css/%.css : $(SRC_CSS)/%.css
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"
	$Qsed -i 's#resources\.rero\.ch/ils#resources\.rero\.ch/ils/pilot#g' "$@"

$(PILOT_DIR)/images : $(PILOT_IMG_FILES)
	$Qmkdir -p $(@D)

$(PILOT_DIR)/images/logo-global.svg: logo-global.pilot.svg
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"

$(PILOT_DIR)/images/logo-%.svg : $(SRC_IMG)/logo-%.svg
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"

static: $(TEST_DIR)/css $(TEST_DIR)/images $(PILOT_DIR)/css $(PILOT_DIR)/images

static.tar.gz: static
	$Qtar cfz "$@" --directory=static/ pilot test


## For o9.re ##

$(O9_DIR)/css : $(O9_CSS_FILES)

$(O9_DIR)/ils/css/%.css : $(SRC_CSS)/%.css
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"
	$Qsed -i 's#resources\.rero\.ch#o9\.re#g' "$@"

$(O9_DIR)/images : $(O9_IMG_FILES)

$(O9_DIR)/ils/images/%.svg : $(SRC_IMG)/%.svg
	$Qmkdir -p $(@D)
	$Qcp "$<" "$@"

$(O9_DIR): $(O9_DIR)/css $(O9_DIR)/images

static-o9.tar.gz: static-o9
	$Qtar cfz "$@" --directory=static-o9/ ils

# To clean generated files
.PHONY: clean

clean:
	$Qrm -rf static/ static-pilot/ static-o9/ *.tar.gz

