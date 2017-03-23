#!/bin/sh

TMPFILE=$(mktemp) || exit 1

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
SCRIPTPATH=`dirname $SCRIPT`

R --no-restore --no-save --slave --quiet --args $1 $2 $3 $4 $5 $6 $7 $8 $9 < ${SCRIPTPATH}/detectCNAsOnDOC.R 2> $TMPFILE

EXITCODE=$?

if [ "$EXITCODE" -ne "0" ]; then
        echo "ERROR"
        cat $TMPFILE >&2
fi

rm $TMPFILE
exit $EXITCODE

