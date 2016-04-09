#!/bin/sh

STEAMBLENDER="${HOME}/.steam/steam/steamapps/common/Blender/blender"
BLENDER="blender"

DEFAULTFILE="scenes/default.blend"
PROJECTDIR="${HOME}/Documents/BlenderProjects"
if [ -d "${HOME}/Dokumentumok" ]; then
    PROJECTDIR="${HOME}/Dokumentumok/BlenderProjects"
fi
if [ -d "${HOME}/BlenderProjects" ]; then
    PROJECTDIR="${HOME}/BlenderProjects"
fi
if [ -d "${HOME}/Projects" ]; then
    PROJECTDIR="${HOME}/Projects"
fi
if [ -d "${HOME}/Projects/Blender" ]; then
    PROJECTDIR="${HOME}/Projects/Blender"
fi

# Check Blender Installation
if [ -f "/usr/bin/blender" ]; then
    echo "Found Blender Installation from packages"
    BLENDER="/usr/bin/blender"
fi
if [ -f "${STEAMBLENDER}" ]; then
    echo "Found Blender Installation from Steam"
    BLENDER="${STEAMBLENDER}"
fi

CURRDIR=`pwd`
if [ "${2}" != "" ]; then
    CURRDIR="${2}"
    
    if [ `echo "${CURRDIR}" | awk '{print substr ($0, 1, 1)}'` = "%" ] || [ `echo "${CURRDIR}" | awk '{print substr ($0, 1, 1)}'` = "\\" ]; then
	CURRDIR="${PROJECTDIR}/"`echo "${CURRDIR}" | awk '{print substr ($0, 2, length)}'`
    fi
    
    if [ `echo "${CURRDIR}" | awk '{print substr ($0, length, 1)}'` = "/" ]; then
	CURRDIR="${CURRDIR%?}"
    fi

    if [ "${2}" = "." ]; then
	CURRDIR=`pwd`
    fi
fi
PROJECTNAME=`basename "${CURRDIR}"`

DIRS="
renders
assets
scenes
plugins
scripts
sourceimages
"

echo "I will use blender from ${BLENDER}"
echo "Project Directory: ${CURRDIR}"

create() {
    if [ ! -d "${CURRDIR}" ]; then
	mkdir "${CURRDIR}"
    fi
    
    echo "CreateDirectories:"
    for d in ${DIRS}; do
	if [ "${d}" != "" ]; then
	    if [ ! -d "${CURRDIR}/${d}" ]; then
		echo "${CURRDIR}/${d}"
		mkdir "${CURRDIR}/${d}"
	    else
		echo "${CURRDIR}/${d} alredy exists"
	    fi
	fi
    done
    
}

open() {
    
    if [ ! -f "${CURRDIR}/${DEFAULTFILE}" ]; then
	touch "${CURRDIR}/${DEFAULTFILE}"
    fi
    ${BLENDER} "${CURRDIR}/${DEFAULTFILE}"
}

compress() {
    TARTARGET="${1}"
    
    echo "Compress \"${CURRDIR}/\" into ${TARTARGET}"
    tar czf "${TARTARGET}" --directory="${CURRDIR}" .
}

load() {
    TARTARGET="${1}"
    
    echo "Decompress to \"${CURRDIR}/\" from ${TARTARGET}"
    tar xzf "${TARTARGET}" --directory="${CURRDIR}/"
}

dbbackup() {
    if [ ! -d "${HOME}/Dropbox/Projects" ]; then
	mkdir "${HOME}/Dropbox/Projects/"
    fi
    if [ ! -d "${HOME}/Dropbox/Projects/BlenderProjects" ]; then
	mkdir "${HOME}/Dropbox/Projects/BlenderProjects"
    fi
    
    BFILENAME="${HOME}/Dropbox/Projects/BlenderProjects/${PROJECTNAME}.tar.gz"
    if [ -f "${BFILENAME}" ]; then
	rm "${BFILENAME}"
    fi
    
    compress "${BFILENAME}"
}

dbrecover() {
    echo "Recover backuped files with keeping new files"
    load "${HOME}/Dropbox/Projects/BlenderProjects/${PROJECTNAME}.tar.gz"
}

dbrollback() {
    echo "Removing all new files"
    rm -r "${CURRDIR}"
    mkdir "${CURRDIR}"
    dbrecover
}

help() {
    cat << HELP
Created By nv8h
------------------------------------------
${0} command project-folder [arg0] [arg1] ... [blender]

Commands:
    help	-	Show help
    create	-	Create a project
    open	-	Open a project default.blend file
    compress	-	Compress project folder to tar.gz
    load	-	Load files from tar.gz to our project folder (!overwrite files)
    
    db-backup	-	Move Compressed Project Files To Dropbox
    db-recover	-	Update Project From Dropbox Backup (keep new files)
    db-rollback	-	Revert Project (removes new files)
    
Examples:
    ${0} create ./test
    ${0} open ./test
    ${0} compress ./test test.tgz
    ${0} load ./test test.tgz
    ${0} db-backup ./test
    ${0} db-recover ./test
    ${0} db-rollback ./test


HELP
}

case "${1}" in
    "create"|"+"|"c")
	create
	;;
    
    "open"|"o")
	open
	;;
    
    "compress")
	compress "${3}"
	;;
    
    "load"|"l")
	load "${3}"
	;;
    
    "dropbox-backup"|"dbbackup"|"dbb"|"dropbox-update"|"dbupdate"|"dbu")
	dbbackup
	;;
    
    "dropbox-recover"|"dbr")
	dbrecover
	;;
    
    "dropbox-rollback"|"dbrollback")
	dbrollback
	;;
    
    *|"help")
	help;
	;;
esac



