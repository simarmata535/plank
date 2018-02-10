include $(top_srcdir)/Makefile.common

VAPIDIR = $(top_srcdir)/vapi

BUILT_SOURCES = \
	docky-calendar-resources.c \
	$(NULL)

libdocklet_calendar_la_LTLIBRARIES = libdocklet-calendar.la

libdocklet_calendar_ladir = $(pkglibdir)/docklets

libdocklet_calendar_la_VALASOURCES = \
	CalendarDockItem.vala \
	CalendarDocklet.vala \
	CalendarPreferences.vala \
	$(NULL)

nodist_libdocklet_calendar_la_SOURCES = \
	$(BUILT_SOURCES) \
	$(libdocklet_calendar_la_VALASOURCES:.vala=.c) \
	$(NULL)

libdocklet_calendar_la_VALAFLAGS = \
	$(PLANK_CORE_VALAFLAGS) \
	$(VAPIDIR)/config.vapi \
	--vapidir $(top_srcdir)/vapi \
	--vapidir $(top_builddir)/lib \
	--pkg plank \
	$(NULL)

libdocklet_calendar_la_LIBADD = \
	$(PLANK_CORE_LIBS) \
	$(NULL)

libdocklet_calendar_la_LDFLAGS = \
	$(DOCKLET_LDFLAGS) \
	$(PLANK_CORE_LDFLAGS) \
	$(top_builddir)/lib/libplank.la \
	$(NULL)

libdocklet_calendar_la_CFLAGS = \
	$(PLANK_CORE_CFLAGS) \
	-include config.h \
	-I$(top_builddir)/lib \
	$(NULL)

docky-calendar-resources.c: $(srcdir)/calendar.gresource.xml Makefile $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir $(srcdir) $(srcdir)/calendar.gresource.xml)
	$(AM_V_GEN) XMLLINT=$(XMLLINT) $(GLIB_COMPILE_RESOURCES) --target $@ --sourcedir $(srcdir) --generate --c-name docky_calendar $<

$(libdocklet_calendar_la_VALASOURCES:.vala=.c): libdocklet_calendar_la_vala.stamp

libdocklet_calendar_la_vala.stamp: $(libdocklet_calendar_la_VALASOURCES) $(top_builddir)/lib/plank.vapi Makefile
	$(AM_V_VALA)$(VALAC) \
		$(libdocklet_calendar_la_VALAFLAGS) \
		-C \
		$(filter %.vala %.c,$^)
	$(AM_V_at)touch $@

CLEANFILES = \
	libdocklet_calendar_la_vala.stamp \
	$(nodist_libdocklet_calendar_la_SOURCES) \
	$(NULL)

EXTRA_DIST = \
	$(libdocklet_calendar_la_VALASOURCES) \
	calendar.gresource.xml \
	themes/elementary/calendar-drop-shadow.svg \
	themes/elementary/calendar-face.svg \
	themes/elementary/calendar-face-shadow.svg \
	themes/elementary/calendar-frame.svg \
	themes/elementary/calendar-glass.svg \
	themes/elementary/calendar-marks.svg \
	themes/gnome/calendar-drop-shadow.svg \
	themes/gnome/calendar-face.svg \
	themes/gnome/calendar-face-shadow.svg \
	themes/gnome/calendar-frame.svg \
	themes/gnome/calendar-glass.svg \
	themes/gnome/calendar-marks.svg \
	$(NULL)

