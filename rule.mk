# Define flags
#------------------------------------------

CFLAGS    += -g -O2 -Wall -I$(TARGET_STAGING_INC) -lpthread
CXXFLAGS  += -g -O2 -Wall

LDFLAGS   += -L$(TARGET_STAGING_LIB)

ifneq ($(SHARED_LIBRARY),)
CFLAGS   += -fpic
CXXFLAGS += -fpic
endif

# Define file filter
#------------------------------------------

SRCEXTS = .c .cpp

SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))

SRC_C   = $(filter-out %.cpp,$(SOURCES))
SRC_CXX = $(filter-out %.c,$(SOURCES))
OBJS    = $(addsuffix .o, $(basename $(SOURCES)))
DEPS    = $(OBJS:.o=.d)

# Define compile and link variables.
#------------------------------------------

DEPEND.c    = $(CC) -MM $(CFLAGS) -E -MQ $(patsubst %.c, %.o, $<) $<
DEPEND.cxx  = $(CC) -MM $(CXXFLAGS) -E -MQ $(patsubst %.cpp, %.o, $<) $<
COMPILE.c   = $(CC)  $(CFLAGS) -c
COMPILE.cxx = $(CXX) $(CXXFLAGS) -c
LINK.c      = $(CC)  $(CFLAGS) $(LDFLAGS)
LINK.cxx    = $(CXX) $(CXXFLAGS) $(LDFLAGS)

# Define targets
#------------------------------------------

.PHONY: all install clean distclean help

# Delete the default suffixes
.SUFFIXES:

all: $(PROGRAM) $(STATIC_LIBRARY) $(SHARED_LIBRARY)

# Rules for creating dependency files (.d).
#------------------------------------------

%.d:%.c
	@$(DEPEND.c) >> $@

%.d:%.cpp
	@$(DEPEND.cxx) >> $@

# Rules for generating object files (.o).
#----------------------------------------

%.o:%.c
	$(COMPILE.c) $< -o $@

%.o:%.cpp
	$(COMPILE.cxx) $< -o $@

# Rules for generating the executable.
#-------------------------------------

ifneq ($(PROGRAM),)
$(PROGRAM):$(OBJS)
ifeq ($(SRC_CXX),)              # Only C program
	$(LINK.c)   $(OBJS) $(LIBS) -o $@ $(LOCAL_LIB)
else                            # C++, or C and C++ program
	$(LINK.cxx) $(OBJS) $(LIBS) -o $@ $(LOCAL_LIB)
endif
endif

ifneq ($(STATIC_LIBRARY),)
$(STATIC_LIBRARY):$(OBJS)
	$(AR) -r $@ $(OBJS) $(LIBS)
endif

ifneq ($(SHARED_LIBRARY),)
$(SHARED_LIBRARY):$(OBJS)
	$(CC) -shared $(OBJS) $(LIBS) -o $@
endif

ifneq ($(MAKECMDGOALS), clean)
ifneq ($(DEPS),)
sinclude $(DEPS)
endif
endif

clean:
	@$(RM) $(OBJS) $(PROGRAM) $(STATIC_LIBRARY) $(SHARED_LIBRARY) $(DEPS)

distclean: clean

# Show help.
help:
	@echo 'Usage: make [TARGET]'
	@echo 'TARGETS:'
	@echo '  all       (=make) compile and link.'
	@echo '  clean     clean objects and the executable file.'
	@echo '  show      show variables (for debug use only).'
	@echo '  help      print this message.'

# Show variables (for debug use only.)
show:
	@echo 'PROGRAM     :' $(PROGRAM)
	@echo 'STATIC_LIBRARY     :' $(STATIC_LIBRARY)
	@echo 'SHARED_LIBRARY     :' $(SHARED_LIBRARY)
	@echo 'SRCDIRS     :' $(SRCDIRS)
	@echo 'SOURCES     :' $(SOURCES)
	@echo 'SRC_CXX     :' $(SRC_CXX)
	@echo 'SRC_C       :' $(SRC_C)
	@echo 'OBJS        :' $(OBJS)
	@echo 'DEPS        :' $(DEPS)
	@echo 'DEPEND.c    :' $(DEPEND.c)
	@echo 'DEPEND.cxx  :' $(DEPEND.cxx)
	@echo 'COMPILE.c   :' $(COMPILE.c)
	@echo 'COMPILE.cxx :' $(COMPILE.cxx)
	@echo 'LINK.c      :' $(LINK.c)
	@echo 'LINK.cxx    :' $(LINK.cxx)

