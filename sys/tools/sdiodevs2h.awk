#! /usr/bin/awk -f
#-
#	$NetBSD: usb/devlist2h.awk,v 1.9 2001/01/18 20:28:22 jdolecek Exp $
#
# SPDX-License-Identifier: BSD-4-Clause
#
# Copyright (c) 1995, 1996 Christopher G. Demetriou
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by Christopher G. Demetriou.
# 4. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

function usage()
{
	print "usage: sdiodevs2h.awk <srcfile> [-d|-h]";
	exit 1;
}

function header(file)
{
	printf("/*\n") > file
	printf(" * THIS FILE IS AUTOMATICALLY GENERATED.  DO NOT EDIT.\n") \
	    > file
	printf(" */\n") > file
}

function vendor(hfile)
{
	nvendors++

	vendorindex[$2] = nvendors;		# record index for this name, for later.
	vendors[nvendors, 1] = $2;		# name
	vendors[nvendors, 2] = $3;		# id
	if (hfile)
		printf("#define\tSDIO_VENDOR_ID_%s\t%s\t", vendors[nvendors, 1],
		    vendors[nvendors, 2]) > hfile
	i = 3; f = 4;

	# comments
	ocomment = oparen = 0
	if (f <= NF) {
		if (hfile)
			printf("\t/* ") > hfile
		ocomment = 1;
	}
	while (f <= NF) {
		if ($f == "#") {
			if (hfile)
				printf("(") > hfile
			oparen = 1
			f++
			continue
		}
		if (oparen) {
			if (hfile)
				printf("%s", $f) > hfile
			if (f < NF && hfile)
				printf(" ") > hfile
			f++
			continue
		}
		vendors[nvendors, i] = $f
		if (hfile)
			printf("%s", vendors[nvendors, i]) > hfile
		if (f < NF && hfile)
			printf(" ") > hfile
		i++; f++;
	}
	if (oparen && hfile)
		printf(")") > hfile
	if (ocomment && hfile)
		printf(" */") > hfile
	if (hfile)
		printf("\n") > hfile
}

function product(hfile)
{
	nproducts++

	products[nproducts, 1] = $2;		# vendor name
	products[nproducts, 2] = $3;		# product id
	products[nproducts, 3] = $4;		# id
	if (hfile)
		printf("#define\tSDIO_DEVICE_ID_%s_%s\t%s\t", \
		  products[nproducts, 1], products[nproducts, 2], \
		  products[nproducts, 3]) > hfile

	i=4; f = 5;

	# comments
	ocomment = oparen = 0
	if (f <= NF) {
		if (hfile)
			printf("\t/* ") > hfile
		ocomment = 1;
	}
	while (f <= NF) {
		if ($f == "#") {
			if (hfile)
				printf("(") > hfile
			oparen = 1
			f++
			continue
		}
		if (oparen) {
			if (hfile)
				printf("%s", $f) > hfile
			if (f < NF && hfile)
				printf(" ") > hfile
			f++
			continue
		}
		products[nproducts, i] = $f
		if (hfile)
			printf("%s", products[nproducts, i]) > hfile
		if (f < NF && hfile)
			printf(" ") > hfile
		i++; f++;
	}
	if (oparen && hfile)
		printf(")") > hfile
	if (ocomment && hfile)
		printf(" */") > hfile
	if (hfile)
		printf("\n") > hfile
}

function dump_dfile(dfile)
{
	printf("\n") > dfile
	printf("const struct sdio_knowndev sdio_knowndevs[] = {\n") > dfile
	for (i = 1; i <= nproducts; i++) {
		printf("\t{\n") > dfile
		printf("\t    SDIO_VENDOR_ID_%s, SDIO_DEVICE_ID_%s_%s,\n",
		    products[i, 1], products[i, 1], products[i, 2]) > dfile
		printf("\t    ") > dfile
		printf("0") > dfile
		printf(",\n") > dfile

		vendi = vendorindex[products[i, 1]];
		printf("\t    \"") > dfile
		j = 3;
		needspace = 0;
		while (vendors[vendi, j] != "") {
			if (needspace)
				printf(" ") > dfile
			printf("%s", vendors[vendi, j]) > dfile
			needspace = 1
			j++
		}
		printf("\",\n") > dfile

		printf("\t    \"") > dfile
		j = 4;
		needspace = 0;
		while (products[i, j] != "") {
			if (needspace)
				printf(" ") > dfile
			printf("%s", products[i, j]) > dfile
			needspace = 1
			j++
		}
		printf("\",\n") > dfile
		printf("\t},\n") > dfile
	}
	for (i = 1; i <= nvendors; i++) {
		printf("\t{\n") > dfile
		printf("\t    SDIO_VENDOR_ID_%s, 0,\n", vendors[i, 1]) > dfile
		printf("\t    SDIO_KNOWNDEV_NOPROD,\n") > dfile
		printf("\t    \"") > dfile
		j = 3;
		needspace = 0;
		while (vendors[i, j] != "") {
			if (needspace)
				printf(" ") > dfile
			printf("%s", vendors[i, j]) > dfile
			needspace = 1
			j++
		}
		printf("\",\n") > dfile
		printf("\t    NULL,\n") > dfile
		printf("\t},\n") > dfile
	}
	printf("\t{ 0, 0, 0, NULL, NULL, }\n") > dfile
	printf("};\n") > dfile
}

BEGIN {

nproducts = nvendors = 0
# Process the command line
for (i = 1; i < ARGC; i++) {
	arg = ARGV[i];
	if (arg !~ /^-[dh]+$/ && arg !~ /devs$/)
		usage();
	if (arg ~ /^-.*d/)
		dfile="sdiodevs_data.h"
	if (arg ~ /^-.*h/)
		hfile="sdiodevs.h"
	if (arg ~ /devs$/)
		srcfile = arg;
}
ARGC = 1;
line=0;

while ((getline < srcfile) > 0) {
	line++;
	if (line == 1) {
		if (dfile)
			header(dfile)
		if (hfile)
			header(hfile)
	}
	if ($1 == "vendor") {
		vendor(hfile)
		continue
	}
	if ($1 == "product") {
		product(hfile)
		continue
	}
	if ($0 == "")
		blanklines++
	if (hfile)
		print $0 > hfile
	if (blanklines < 2 && dfile)
	    print $0 > dfile
}

# print out the match tables

if (dfile)
	dump_dfile(dfile)
}
