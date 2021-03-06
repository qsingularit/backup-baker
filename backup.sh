#!/bin/sh
set -e
DUMPDATE=$(date +%F-%H-%M-%S-%Z)

# S3 Credentials export to variables from ENV
  export AWS_ACCESS_KEY_ID=${S3_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${S3_SECRET_ACCESS_KEY}
  export AWS_DEFAULT_REGION=${S3_REGION}

# FTP credentials export to variables from ENV
  export FTP_HOSTNAME=${FTP_HOST}
  export FTP_USERNAME=${FTP_USER}
  export FTP_PASSWORD=${FTP_PASS}

# If no S3 info provided, do a local backup only.
Local_Backup () {
    if [[ "$(ls -A ${SPATH})" ]]; then
        echo "Creating individual full local backup to ${DPATH}"
        find . -type d -maxdepth 1 -mindepth 1 -exec tar cf ${DPATH}/{}-${DUMPDATE}.tar {}  \;
    else
        echo "Found an empty directory. Nothing to do."
    fi
}

 #S3 offload function to call on each backup file
Local_To_Remote_Backup (){

    # S3 Offload
    Copy_To_S3 () {
         SRC_FILE=$1
         DST_FILE=$2
            echo "Uploading ${DST_FILE} to S3 Bucket ${S3_BUCKET}" &&
            aws s3 cp ${DPATH}/${DST_FILE} s3://${S3_BUCKET}/${S3_PREFIX}/${DEST_FILE}

                if [[ $? != 0 ]]; then
                    >&2 echo "${DUMPDATE} Error uploading ${DEST_FILE} to S3" >> /var/log/bb.log
                fi
    }

    # FTP Offload
    Copy_To_FTP (){
            DST_FILE=$1
            echo "Uploading ${DST_FILE} to FTP server ${FTP_HOSTNAME}";
            lftp ftp://${FTP_USERNAME}:${FTP_PASSWORD}@${FTP_HOSTNAME} -e "set ftp:ssl-allow no; put -c ${DPATH}/${DST_FILE}; exit"

            if [[ $? != 0 ]]; then
                    >&2 echo "#${DUMPDATE} Error uploading ${DEST_FILE} to FTP" >> /var/log/bb.log
            fi
    }

    # Do a local backup first, after upload to S3 the latest modified.
    Local_Backup

    # Search latest modified file and copy it to S3
    FILELIST=$(find ${DPATH} 2>/dev/null -type f -maxdepth 1 -mindepth 1 -mtime -1 -print0 | cut -c 9- | sort)

    for i in ${FILELIST}; do
        echo "Creating individual full backup of ${i} from ${DPATH} to S3 ${S3_BUCKET}/${S3_PREFIX}"
        Copy_To_S3 ${i} ${i}
    done

        if [[ $? == 0 ]]; then
            echo "Backup to S3 complete!"
        fi

    if [[ ${FTP_HOSTNAME} != "null" ]]; then
        for i in ${FILELIST}; do
            echo "Copy full backup of ${i} to FTP ${FTP_HOSTNAME}"
            Copy_To_FTP ${i}
        done
    else
        echo "No FTP configured, use S3 offload only"
    fi
}



# Main logic. If no S3 creds - do local backup, if anything else do more

if [[ "${S3_ACCESS_KEY_ID}" == "null" ]] || [[ "${S3_SECRET_ACCESS_KEY}" == "null" ]] || [[ "${S3_BUCKET}" == "null" ]]; then

    echo "No AWS S3 credentials or bucket is supplied. Making a local backup only."
    Local_Backup
else

    Local_To_Remote_Backup

fi

if [[ $? == 0 ]]; then
    echo "Backup to S3 complete! Let's do some cleanup"
    source /usr/share/rotate.sh
fi

exit 0
