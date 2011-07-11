AC_INIT([geometry], 0.1) dnl package name, version

dnl find what R uses for the C compiler and flags
: ${R_HOME=`R RHOME`}
CC=`"${R_HOME}/bin/R" CMD config CC`
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
AC_PROG_CC

if test "${GCC}" = yes; then
  dnl check that it accepts the flags we're looking for
  PKG_CFLAGS=
  for option in -fno-strict-aliasing; do
	SAVE_CFLAGS="$CFLAGS"
	CFLAGS="$CFLAGS $option"
	AC_TRY_COMPILE([], [], has_option=yes, has_option=no)
	if test "$has_option" = "no"; then
		CFLAGS="$SAVE_CFLAGS"
	else
		PKG_CFLAGS="$PKG_CFLAGS $option"
	fi
	AC_MSG_CHECKING([whether $CC understands $option])
	AC_MSG_RESULT($has_option)
  done
fi

dnl write out the Makevars file
AC_SUBST(PKG_CFLAGS)
AC_CONFIG_FILES([src/Makevars])

dnl done
AC_OUTPUT
