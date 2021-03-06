#!/bin/sh

STEAMBLENDER="${HOME}/.steam/steam/steamapps/common/Blender/blender"
BLENDER="blender"

HISTORYFILE=".history"
DEFAULTFILE="scenes/default.blend"
PROJECTDIR="${HOME}/Documents/BlenderProjects"
ACTION="${1}"
ARG0="${2}"

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

if [ ! -d "${PROJECTDIR}" ]; then
    mkdir "${PROJECTDIR}"
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

CURRDIR=""
if [ "${DEFAULTBLENDERPROJECT}" = "" ]; then
    DEFAULTBLENDERPROJECT="${2}"
    ARG0="${3}"
fi

if [ "${DEFAULTBLENDERPROJECT}" != "" ]; then
    CURRDIR="${DEFAULTBLENDERPROJECT}"
    
    if [ `echo "${CURRDIR}" | awk '{print substr ($0, 1, 1)}'` = "%" ] || [ `echo "${CURRDIR}" | awk '{print substr ($0, 1, 1)}'` = "\\" ]; then
	CURRDIR="${PROJECTDIR}/"`echo "${CURRDIR}" | awk '{print substr ($0, 2, length)}'`
    fi
    
    if [ `echo "${CURRDIR}" | awk '{print substr ($0, length, 1)}'` = "/" ]; then
	CURRDIR="${CURRDIR%?}"
    fi

    if [ "${CURRDIR}" = "." ]; then
	CURRDIR=`pwd`
    fi
fi
PROJECTNAME=`basename "${CURRDIR}"`

DIRS="
ideas
renders
assets
scenes
plugins
scripts
sourceimages
"

echo "I will use blender from ${BLENDER}"
echo "Project Directory: ${CURRDIR}"

logAction() {
    DT=`date +"%Y-%m-%d %T"`
    echo "[${DT}] ${USERNAME} - $*" >> "${CURRDIR}/${HISTORYFILE}"
}

createJSON() {
    cat <<EOF_JSON>"${CURRDIR}/project.json"
{
    "type": "shell",
    "version": "v0.1",
    
    "user": "${USERNAME}",
    
    "project": {
	"name": "${PROJECTNAME}",
	"root": "${CURRDIR}",
	"history-file": "${HISTORYFILE}",
	"directory-list": "`echo "${DIRS}" | tr '\n' ' '`"
    }
}
EOF_JSON
}

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
    
    cp "${0}" "${CURRDIR}/blenderproject"
}

open() {
    if [ "${1}" != "" ]; then
	DEFAULTFILE="${1}"
    fi
    
    if [ ! -f "${CURRDIR}/${DEFAULTFILE}" ]; then
	touch "${CURRDIR}/${DEFAULTFILE}"
    fi
    ${BLENDER} "${CURRDIR}/${DEFAULTFILE}"
}

xdgopen() {
    if [ "${1}" != "" ]; then
	DEFAULTFILE="${1}"
    fi
    
    xdg-open "${CURRDIR}/${DEFAULTFILE}"
}

compress() {
    TARTARGET="${1}"
    
    echo "Compress \"${CURRDIR}/\" into ${TARTARGET}"
    tar czf "${TARTARGET}" --directory="${CURRDIR}" .
}

load() {
    TARTARGET="${1}"
    
    cp "${CURRDIR}/${HISTORYFILE}" "${CURRDIR}/${HISTORYFILE}.old"
    echo "Decompress to \"${CURRDIR}/\" from ${TARTARGET}"
    tar xzf "${TARTARGET}" --directory="${CURRDIR}/"
    cp "${CURRDIR}/${HISTORYFILE}.old" "${CURRDIR}/${HISTORYFILE}"
    rm "${CURRDIR}/${HISTORYFILE}.old"
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

    TEMPFILE="/tmp/${PROJECTNAME}${HISTORYFILE}.old"
    cp "${CURRDIR}/${HISTORYFILE}" "${TEMPFILE}"
    rm -r "${CURRDIR}"
    mkdir "${CURRDIR}"
    dbrecover
    cp "${TEMPFILE}" "${CURRDIR}/${HISTORYFILE}"
    rm "${TEMPFILE}"
}

listprojects() {
    ls "${PROJECTDIR}"
    
    
}

help() {
    cat << HELP
Created By nv8h
------------------------------------------
${0} command [project-folder] [arg0] [arg1] ... [blender]

Commands:
    help	-	Show this help
    create	-	Create a project
    open	-	Open a project file (default file: ${DEFAULTFILE})
    xdg-open	-	Open a file with the default application
    save	-	Compress project folder to tar.gz
    load	-	Load files from tar.gz to our project folder (!overwrite files)
    
    default	-	Set Default Project
    
    dbbackup	-	Move Compressed Project Files To Dropbox 
    dbrecover	-	Update Project From Dropbox Backup (!overwrite files)
    dbrollback	-	Revert Project (removes new files)
    
Examples:
    ${0} create ./test
    ${0} open ./test scenes/newscene.blend
    ${0} xdg-open ./test scripts/custom.py
    ${0} save ./test test.tgz
    ${0} load ./test test.tgz
    ${0} dbbackup ./test
    ${0} dbrecover ./test
    ${0} dbrollback ./test
    ${0} default ./test


Shorts:
    help	-	h
    create	-	c
    open	-	o
    xdg-open	-	xo
    save	-	s, tar, tgz, tarsave, tgzsave, compress
    load	-	l, tarload, tgzload, decompress
    default	-	d, default-project, set-default-project
    
    execute	-	e
    
    dbbackup	-	dbb, dbu, dbupdate, dropbox-backup, dropbox-update
    dbrecover	-	dbr, dbrevert, dropbox-recover, dropbox-revert
    dbrollback	-	dropbox-rollback
HELP
}

beforerun() {
    if [ "${CURRDIR}" != "" ]; then
	
	if [ ! -f "${CURRDIR}/${HISTORYFILE}" ]; then
	    logAction "Missing history file"
        fi
    fi
}

afterrun() {
    if [ "${CURRDIR}" != "" ]; then
	logAction "Command: $*"
	logAction "Executed: ${ACTION}"
	
	if [ ! -f "${CURRDIR}/project.json" ]; then
	    createJSON
        fi
    fi
}


beforerun $0 $*
case "${ACTION}" in
    "create"|"c")
	ACTION="create"
	create
	;;
    
    "set-default-project"|"default-project"|"default"|"d")
	ACTION="set-default-project"
	if [ "${ARG0}" = "" ]; then
	    STR="export DEFAULTBLENDERPROJECT=\"${CURRDIR}\""
	    export DEFAULTBLENDERPROJECT="${CURRDIR}"
	else
	    STR="export DEFAULTBLENDERPROJECT=\"${ARG0}\""
	    export DEFAULTBLENDERPROJECT="${ARG0}"
	fi
	echo "Run the Following command: \n\n\t${STR}\n\n"
	# We do not have to log this action
	exit
	;;
    
    "open"|"o")
	ACTION="open"
	open ${ARG0}
	;;
	
    "xdg-open"|"xo")
	ACTION="xdg-open"
	xdgopen ${ARG0}
	;;
    
    "compress"|"tar"|"tgz"|"tgzsave"|"tarsave"|"save"|"s")
	ACTION="tarsave"
	compress "${ARG0}"
	;;
    
    "execute"|"e")
	ACTION="execute"
	CDIR=`pwd`
	cd "${CURRDIR}"
	${ARG0}
	cd "${CDIR}"
	;;
    
    "decompress"|"tgzload"|"tarload"|"load"|"l")
	ACTION="tarload"
	load "${ARG0}"
	;;
    
    "dropbox-backup"|"dbbackup"|"dbb"|"dropbox-update"|"dbupdate"|"dbu")
	ACTION="dropbox-update"
	dbbackup
	;;
    
    "dropbox-revert"|"dbrevert"|"dropbox-recover"|"dbrecover"|"dbr")
	ACTION="dropbox-recover"
	dbrecover
	;;
    
    "dropbox-rollback"|"dbrollback")
	ACTION="dropbox-rollback"
	dbrollback
	;;
    
    "list"|"listprojects"|"lp"|"ls")
	ACTION="list"
	listprojects
	;;
    
    *|"help"|"h")
	ACTION="help"
	help;
	;;
esac
afterrun $0 $*




