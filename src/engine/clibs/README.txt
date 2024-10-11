All dynamic libraries in this directory will be used by creq
depending on running OS.

Make sure to point:
    * LD_LIBRARY_PATH on Linux to the linux directory
    * DYLD_FALLBACK_LIBRARY_PATH on OSX to the osx directory
    * PATH on Windows to the windows directory

Doing this will allow the libraries required by creqm, which
themselves require other dynamic libraries, to find what they
need in development.

For example, if we do `creq("luasteam.so")` on a Linux machine
in development, the following will happen in order:
    1) creq will call `require("clibs/linux/luasteam.so")`.
    2) The 'luasteam.so' library itself will try to load
       'libsteam_api.so' from various directories all over the
       system, including those given in LD_LIBRARY_PATH.
    3) 'clibs/linux/libsteam_api.so' will be found and loaded.

When the same `creq("luasteam.so")` is called on a Linux machine
from an executable, we don't need to provide a LD_LIBRARY_PATH
so long as we place the libraries in the same directory.
