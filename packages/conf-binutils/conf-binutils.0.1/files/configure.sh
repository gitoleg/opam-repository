#!/bin/sh

# check that objdump is installed, if several objdumps are installed
# then collect all possible objdump targets, where a target of an
# objdump is defined syntactically <target>-objdump.
# all found targets are written into config file in OCaml list syntax
# Note: we specifically remove "llvm-objdump" as it is not a part of
# binutils.

TARGETS=
FOUND=
OBJDUMP=
OBJDUMPS=

check_objdump() {
    [ -n "$OBJDUMP" ] && FOUND=1
}


add_target() {
    if [ -z "$TARGETS" ]; then
        TARGETS="\\\"${1}\\\""
    else
        TARGETS="\\\"${1}\\\"; $TARGETS"
    fi
}


collect_targets() {
    IFS="
"
   for path in $OBJDUMPS; do
        file=`basename "${path}"`
        pref=${file%-objdump}
        if [ $pref -a -f $path -a -x $path -a "x${pref}" != "xllvm" -a "x${pref}" != "xobjdump" ]; then
            if [ `which ${file}`  ]; then
                FOUND=1
                add_target $pref
            fi
        fi
    done
}

get_checksum() {
    if [ `opam config var os` = "linux" ]; then
        checksum=`md5sum $1 | cut -d' ' -f 1` || true
    elif  [ `opam config var os` = "macos" ]; then
        checksum=`md5 -q $1` || true
    else
        checksum=""
    fi
}

add_filedepends() {
    get_checksum $1
    if [ ! -z $checksum ]; then
        depends="[ \"$1\" \"md5=$checksum\" ] $depends"
    fi
}


if   [ "is_$1" = "is_linux" ]; then
    OBJDUMP=`which objdump`
    OBJDUMPS=`locate -r 'objdump$'`
elif [ "is_$1" = "is_macos" ]; then
    OBJDUMP=`which gobjdump`
    OBJDUMPS=`mdfind -name objdump`
else
    echo "unsupported OS"
    exit 1
fi

check_objdump
collect_targets
add_filedepends $OBJDUMP

if [ -z "$FOUND" ]; then
    echo "Failed to find objdump executable(s)"
    exit 1
fi



filename="conf-binutils.config"
cat > $filename <<EOF
opam-version: "2.0.0"
EOF

if [ "$depends" != "" ]; then
    echo "file-depends: [ $depends ]" >> $filename
fi

cat >> $filename <<EOF
variables {
  objdump: "${OBJDUMP}"
  targets: "[${TARGETS}]"
}
EOF
