# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := freetype
$(PKG)_WEBSITE  := https://www.freetype.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.9
$(PKG)_CHECKSUM := e6ffba3c8cef93f557d1f767d7bc3dee860ac7a3aaff588a521e081bc36f4c8a
$(PKG)_SUBDIR   := freetype-$($(PKG)_VERSION)
$(PKG)_FILE     := freetype-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://$(SOURCEFORGE_MIRROR)/project/freetype/freetype2/$(shell echo '$($(PKG)_VERSION)' | cut -d . -f 1,2,3)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc bzip2 harfbuzz libpng zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://sourceforge.net/projects/freetype/files/freetype2/' | \
    $(SED) -n 's,.*/\([0-9][^"]*\)/".*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD_COMMON
    cd '$(1)' && GNUMAKE=$(MAKE) ./configure --with-harfbuzz=yes \
        $(MXE_CONFIGURE_OPTS) \
        LIBPNG_CFLAGS="`$(TARGET)-pkg-config libpng --cflags`" \
        LIBPNG_LDFLAGS="`$(TARGET)-pkg-config libpng --libs`" \
        FT2_EXTRA_LIBS="`$(TARGET)-pkg-config libpng --libs`" \
        $(if $(BUILD_STATIC),HARFBUZZ_LIBS="`$(TARGET)-pkg-config harfbuzz --libs` -lharfbuzz_too -lfreetype_too `$(TARGET)-pkg-config glib-2.0 --libs`",)
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install
    ln -sf '$(PREFIX)/$(TARGET)/bin/freetype-config' '$(PREFIX)/bin/$(TARGET)-freetype-config'
endef

define $(PKG)_BUILD
    # alias libharfbuzz and libfreetype to satisfy circular dependence
    # libfreetype should already have been created by freetype-bootstrap.mk
    $(if $(BUILD_STATIC),\
        ln -sf libharfbuzz.a '$(PREFIX)/$(TARGET)/lib/libharfbuzz_too.a' \
        && ln -sf libfreetype.a '$(PREFIX)/$(TARGET)/lib/libfreetype_too.a',)
    $($(PKG)_BUILD_COMMON)
endef