#!/bin/sh
# Shell File Created By István Schoffhauzer
# License: MIT
# 
#

# Set Search Dir
search_dir=~/Music
if [ -d "${1}" ]; then
    search_dir="${1}"
fi

# Set Target Dir
work_dir=~/.local/share/Euro\ Truck\ Simulator\ 2/music

# Set Converter Shell Filename
conv=snd2ogg.file.sh

# Acceptable Extensions
extensions="\.(mp3|m4a|wav|flac)\$"

# Create Converter Shell File
cat << SND2OGG>"${conv}"
#!/bin/sh

FILE="\${1}"
FILENAME=\`basename "\${FILE}"\`
TARGETFILENAME="${work_dir}/\${FILENAME}.ogg"

# If Extension is not acceptable exit
TEST=\`echo "\${FILENAME}" | grep -E "${extensions}"\`
if [ "\${TEST}" = "" ]; then
    exit
fi

# Create Ogg file if not exists
if [ ! -f "\${TARGETFILENAME}" ]; then
    echo "ffmpeg -i \"\${FILENAME}\""
    ffmpeg -i "\${FILE}" "\${TARGETFILENAME}"
fi

SND2OGG
# End Of Converter Shell File Content

# Make converter executable
chmod a+x "${conv}"

# search for files
find "${search_dir}" -type f -exec ./${conv} {} \;

# Remove File Converter
rm "${conv}"