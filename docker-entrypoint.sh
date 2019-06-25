#!/bin/sh
a1="AWS_REGION=\"${AWS_REGION}\""
a2="AWS_REGION_FILE=\"${AWS_REGION_FILE}\""
[ -z "${AWS_REGION_FILE}" ] && a=$a1 || a=$a2

b1="AWS_ID=\"${AWS_ID}\""
b2="AWS_ID_FILE=\"${AWS_ID_FILE}\""
[ -z "${AWS_ID_FILE}" ] && b=$b1 || b=$b2

c1="AWS_SECRET=\"${AWS_SECRET}\""
c2="AWS_SECRET_FILE=\"${AWS_SECRET_FILE}\""
[ -z "${AWS_SECRET_FILE}" ] && c=$c1 || c=$c2

d1="AWS_BUCKET_NAME=\"${AWS_BUCKET_NAME}\""
d2="AWS_BUCKET_NAME_FILE=\"${AWS_BUCKET_NAME_FILE}\""
[ -z "${AWS_BUCKET_NAME_FILE}" ] && d=$d1 || d=$d2

e1="AWS_VERSION=\"${AWS_VERSION}\""
e2="AWS_VERSION_FILE=\"${AWS_VERSION_FILE}\""
[ -z "${AWS_VERSION_FILE}" ] && e=$e1 || e=$e2

f1="SLACK=\"${SLACK}\""
f2="SLACK_FILE=\"${SLACK_FILE}\""
[ -z "${SLACK_FILE}" ] && f=$f1 || f=$f2

g1="SPREADSHEET=\"${SPREADSHEET}\""
g2="SPREADSHEET_FILE=\"${SPREADSHEET_FILE}\""
[ -z "${SPREADSHEET_FILE}" ] && g=$g1 || g=$g2

h="CRON_GENERATE=\"$CRON_GENERATE\""
i="CRON_STATUS=\"$CRON_STATUS\""
j="DEBUG=\"${DEBUG}\""
k="STAGE=\"${STAGE}\""

if ${DEBUG} ; then
    echo "ruby" "index.rb" ${a} ${b} ${c} ${d} ${e} ${f} ${g} "$h" "$i" ${j} ${k}
fi

ruby index.rb ${a} ${b} ${c} ${d} ${e} ${f} ${g} "$h" "$i" ${j} ${k}
