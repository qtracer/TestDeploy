#!/bin/bash

packageName=$1

tar -zxvf ${packageName}.tar $(ls | grep "${packageName}$")
