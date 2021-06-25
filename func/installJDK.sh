#!/bin/bash

rm -f /usr/bin/java
ln -s $(find / -name java | grep "diff/opt/java/openjdk/bin/java") /usr/bin/java


