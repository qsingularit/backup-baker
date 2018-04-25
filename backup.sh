#!/bin/sh
set -e
DUMPDATE=$(date +%F-%H-%M-%S-%Z)


  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=${S3_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${S3_SECRET_ACCESS_KEY}
  export AWS_DEFAULT_REGION=${S3_REGION}

#If no S3 info provided, do a local backup only.
Local_Backup () {
    if [ "$(ls -A ${SPATH})" ]; then
        echo "Creating individual full local backup of ${i} from ${SPATH} to ${DPATH}" &&
        find ${SPATH} -type d -maxdepth 1 -mindepth 1 -exec tar cf ${DPATH}/{}-${DUMPDATE}.tar.gz {}  \;
    else
        echo "Found an empty directory. Nothing to do."
    fi
}

#S3 offload function to call on each backup file
Local_S3_backup (){
    Copy_To_S3 () {
         SRC_FILE=$1
         DST_FILE=$2
            echo "Uploading ${DST_FILE} to S3 Bucket ${S3_BUCKET}" &&
            aws s3 cp ${DPATH}/${DST_FILE} s3://${S3_BUCKET}/${S3_PREFIX}/${DEST_FILE}

                if [ $? != 0 ]; then
                    >&2 echo "Error uploading ${DEST_FILE} on S3"
                fi
    }

#Do a local backup first, after upload to S3 the latest modified.
Local_Backup

#Search latest modified file for past 24 hours or less and copying it to S3
FILELIST=$(find ${DPATH} 2>/dev/null -type f -maxdepth 1 -mindepth 1 -mtime -1 -print0 | cut -c 9- | sort)

for i in ${FILELIST}; do
    echo "Creating individual full backup of ${i} from ${DPATH} to S3 ${S3_BUCKET}/${S3_PREFIX}" &&
    Copy_To_S3 ${i} ${i}
done
    if [ $? == 0 ]; then
        echo "Backup to S3 complete!"
    fi
}

if [ "${S3_ACCESS_KEY_ID}" == "null" ] || [ "${S3_SECRET_ACCESS_KEY}" == "null" ] || [ "${S3_BUCKET}" == "null" ]; then

    echo "No AWS S3 credentials or bucket is supplied. Making a local backup only."
    Local_Backup
else

    Local_S3_backup

fi



