#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

BONGWATERD=${BONGWATERD:-$SRCDIR/bongwaterd}
BONGWATERCLI=${BONGWATERCLI:-$SRCDIR/bongwater-cli}
BONGWATERTX=${BONGWATERTX:-$SRCDIR/bongwater-tx}
BONGWATERQT=${BONGWATERQT:-$SRCDIR/qt/bongwater-qt}

[ ! -x $BONGWATERD ] && echo "$BONGWATERD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BNGWVER=($($BONGWATERCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$BONGWATERD --version | sed -n '1!p' >> footer.h2m

for cmd in $BONGWATERD $BONGWATERCLI $BONGWATERTX $BONGWATERQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BNGWVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BNGWVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
