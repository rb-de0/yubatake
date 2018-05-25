#!/bin/bash

swift run Run boot --env test
DIFF_LENGTH=`bundle exec ridgepole --diff database.yml Schemafile | wc -l`

if [ $DIFF_LENGTH -gt 0 ] ; then
  echo 'schema changes detected' 1>&2
  exit 1
else
  echo 'no changes'
  exit 0
fi
