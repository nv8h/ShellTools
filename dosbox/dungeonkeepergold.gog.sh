#!/bin/sh

BASENAME=`basename "$0"`
CURRENTDIR=`echo "$0"| sed -e "s/\/${BASENAME}//g"`
CONFIGFILE="${CURRENTDIR}/dosboxDK_linux.conf"
DOSBOX="dosbox"
BEFORE=""
COMMAND="keeper.exe"
AFTER=""

checkrequirements() {
    # REquired files
    REQUIRED="dosbox"
    SUCCESS=1
    
    for REQFILE in ${REQUIRED}; do
        EXISTS=0
        
        # Check file in the /usr/bin/ directory
        if [ -f "/usr/bin/${REQFILE}" ]; then
            DOSBOX="/usr/bin/${REQFILE}"
            EXISTS=1
        fi
        
        # Check file in the /bin/ directory
        if [ -f "/bin/${REQFILE}" ]; then
            DOSBOX="/bin/${REQFILE}"
            EXISTS=1
        fi
        
        # Check file in the current directory "./"
        if [ -f "${CURRENTDIR}/${REQFILE}" ]; then
            DOSBOX="${CURRENTDIR}/${REQFILE}"
            EXISTS=1
        fi
        
        # File exists somewhere ?
        if [ ${EXISTS} -eq 0 ]; then
            SUCCESS=0
            echo "${REQFILE} is not exists"
            echo "Please install it from the sources"
        fi
    done
    
    # Exit if any file missing
    if [ ${SUCCESS} -eq 0 ]; then
        exit
    fi
    
}

echo "Current Directory: ${CURRENTDIR}"
echo "Launch Dosbox with Dungeon Keeper Config"

# Call checkrequirements function
checkrequirements

i=1
while [ ${i} -lt ${#} ]; do
    j=`expr ${i} + 1`
    eval PARAM0=\$${i}
    eval PARAM1=\$${j}
    case "${PARAM0}" in
        "-exec")
            COMMAND="${PARAM1}"
        ;;
        "-mode")
            case "${PARAM1}" in
                "server")
                    BEFORE="IPXNET STARTSERVER"
                ;;
                "client")
                    BEFORE="IPXNET CONNECT 127.0.0.1"
                ;;
            esac
        ;;
    esac
    i=`expr ${i} + 2`
done

# Create Linux's Dosbox configuration File
cat << DEFAULT_CONFIG>"${CONFIGFILE}"
[ipx]
ipx=true

[autoexec]
mount c "${CURRENTDIR}"
imgmount d "${CURRENTDIR}/game.inst" -t iso -fs iso
c:
${BEFORE}
${COMMAND}
${AFTER}
exit
DEFAULT_CONFIG

# Run Dosbox
echo "${DOSBOX} -conf \"${CONFIGFILE}\" --command ${COMMAND}"
${DOSBOX} -conf "${CONFIGFILE}"

