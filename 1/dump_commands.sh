#!/bin/bash

mysqldump example > example_dump.sql
mysql sample < example_dump.sql
mysqldump mysql -t help_keyword --where="TRUE LIMIT 100" > help_keywords_100_dump.sql
