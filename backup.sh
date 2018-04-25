#! /bin/sh

set -e
DUMPDATE=$(date +%F-%H-%M-%S-%Z)

if [ "${S3_ACCESS_KEY_ID}" == "null" ] || [ "${S3_SECRET_ACCESS_KEY}" == "null" ] || [ "${S3_BUCKET}" == "null" ]; then

    echo "No AWS S3 credentials or bucket is supplied. Making a local backup only."
    Local_Backup
fi

function Local_Backup () {
    if [ "$(ls -A $SPATH)" ]; then
        find $SPATH -type d -maxdepth 1 -mindepth 1 -exec tar cf $DPATH/{}-${DUMPDATE}.tar.gz {}  \;
    else
        echo "Found an empty directory. Nothing to do."
    fi
}

#S3 offload function to call on each backup file
function Copy_To_S3 () {
  SRC_FILE=$1
  DEST_FILE=$2

  if [ "${S3_ENDPOINT}" == "null" ]; then
    AWS_ARGS=""
  else
    AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
  fi

  echo "Uploading ${DEST_FILE} to S3 Bucket ${$S3_BUCKET}" &&

  cat $SRC_FILE | aws $AWS_ARGS s3 cp - s3://$S3_BUCKET/$S3_PREFIX/$DEST_FILE

  if [ $? != 0 ]; then
    >&2 echo "Error uploading ${DEST_FILE} on S3"
  fi

  rm $SRC_FILE
}

#Search latest modified file for past 24 hours or less and copying it to S3

FILELIST=$(find . 2>/dev/null -type f -maxdepth 1 -mindepth 1 -mtime -1 -print0 | cut -c 3- | sort)

for i in $FILELIST; do

    echo "Creating individual full backup of ${i} from ${$DPATH} to S3 ${S3_BUCKET/$S3_PREFIX} \n" &&

    Copy_To_S3 ${i} ${i}

done

    if [ $? == 0 ]; then
        echo "Backup to S3 complete!"
    fi

