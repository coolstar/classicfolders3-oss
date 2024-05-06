#!/bin/bash
mv .theos/obj/ClassicFolders2.dylib .theos/obj/org.coolstar.classicfolders2.license.signed
ldid -S .theos/obj/org.coolstar.classicfolders2.license.signed
mv .theos/obj/org.coolstar.classicfolders2.license.signed .theos/obj/ClassicFolders2.dylib
