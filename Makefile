NAME = stashtest

LD = $(CC)
RM = rm -f
MKDIR = mkdir -p
VERBOSE ?= 0
CFG ?= release
UNAME := $(shell uname)

WARNINGS = -Wall -Wextra -Wpedantic -Wmissing-include-dirs -Wformat=2 -Wsuggest-attribute=format $(WSHADOW) -Wno-unused-parameter -Wno-missing-field-initializers
CFLAGS = $(WARNINGS) -march=native -fno-exceptions -gdwarf-4 -g2 -I../libgit2/include
CXXFLAGS = -fno-rtti -Woverloaded-virtual
LDFLAGS = -march=native -gdwarf-4 -g2 -Wl,-z,origin -Wl,-rpath,'$$ORIGIN/../../libgit2/build'
LIBS = -Wl,--no-as-needed -lm -ldl -lpthread -lstdc++ ../libgit2/build/libgit2.so

CFILES = \
	stashtest.cpp

ifeq ($(UNAME), Linux)
	LDFLAGS += -Wl,--build-id=sha1
else ifeq ($(UNAME), Darwin)
endif

ifeq ($(CFG), debug)
	ODIR=_debug
	CFLAGS += -O0 -DDEBUG
else
	ODIR=_release
	CFLAGS += -O2 -DNDEBUG
endif

ifeq ($(VERBOSE), 1)
	VERBOSE_PREFIX=
else
	VERBOSE_PREFIX=@
endif

PROJ = $(ODIR)/$(NAME)
$(info Building $(ODIR)/$(NAME)...)

C_OBJS = ${CFILES:%.c=${ODIR}/%.o}
OBJS = ${C_OBJS:%.cpp=${ODIR}/%.o}

all: $(PROJ)

$(ODIR)/$(NAME): $(OBJS)
	@echo "Linking $@...";
	$(VERBOSE_PREFIX)$(LD) $(LDFLAGS) $^ $(LIBS) -o $@

-include $(OBJS:.o=.d)

$(ODIR)/%.o: %.c Makefile
	$(VERBOSE_PREFIX)echo "---- $< ----";
	@$(MKDIR) $(dir $@)
	$(VERBOSE_PREFIX)$(CC) -MMD -MP -std=gnu99 $(CFLAGS) -o $@ -c $<

$(ODIR)/%.o: %.cpp Makefile
	$(VERBOSE_PREFIX)echo "---- $< ----";
	@$(MKDIR) $(dir $@)
	$(VERBOSE_PREFIX)$(CXX) -MMD -MP -std=c++11 $(CFLAGS) $(CXXFLAGS) -o $@ -c $<

.PHONY: clean

clean:
	@echo Cleaning...
	$(VERBOSE_PREFIX)$(RM) $(PROJ)
	$(VERBOSE_PREFIX)$(RM) $(OBJS)
	$(VERBOSE_PREFIX)$(RM) $(OBJS:.o=.d)
