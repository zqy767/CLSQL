#!/bin/bash 
#
# Creates upstream packages
# Programmer: Kevin Rosenberg

set -e # abort on error

PKG=clsql
DEBPKG=cl-sql

PACKAGE_DIR=/usr/local/src/Packages/${DEBPKG}
WORK_DIR=/usr/local/src/Work/${PKG}

VERSION=`sed -n -e "s/${DEBPKG} (\(.*\)-[0-9.]).*/\1/p" < ${WORK_DIR}/debian/changelog  |head -1`
DISTDIR=${PKG}-${VERSION}
DEBDIR=${DEBPKG}-${VERSION}

if [ -z "${VERSION}" ]; then
  echo "Can't find Debian changelog"
  exit 1
fi

cvs commit -m 'Auto commit for Debian build'

if [ -f ${PACKAGE_DIR}/${DEBPKG}_${VERSION}.orig.tar.gz ]; then
  echo "File ${PACKAGE_DIR}/${DEBPKG}_${VERSION}.orig.tar.gz already exists."
  echo -n "Are you sure that you want to create a new upstream archive? (y/N): "
  read answer
  case $answer in
      [Yy]*) nop= ;;
      *) echo "Not building"
	 exit 1
	  ;;
  esac
fi

# Prepare for archive
cd ${WORK_DIR}/..
rm -f ${PKG}_${VERSION}.tar.gz ${DEBPKG}_${VERSION}.orig.tar.gz
rm -rf ${DISTDIR} ${DEBDIR} ${DISTDIR}.zip
cp -a ${WORK_DIR} ${DISTDIR}

echo "Cleaning distribution directory ${DISTDIR}"
cd ${DISTDIR}
make clean
rm -f debian/upload.sh debian/make-debian.sh debian/make-upstream.sh debian/cvsbp-prepare.sh test-suite/test.config
rm -f `find . -type f -name "*.so" -or -name "*.o"`
rm -f `find . -type f -name .cvsignore`
rm -rf `find . -type d -name CVS -or -name .bin`
rm -f `find . -type f -name '*~' -or -name '.#*'  -or -name '#*#' -or -name ".*~"`
rm -f `find doc -type f -name \*.tex -or -name \*.aux -or \
  -name \*.log -or -name \*.out -or -name \*.dvi`
cd ..

echo "Creating upstream archives"
rm -rf ${DISTDIR}/debian
GZIP=-9 tar czf ${DISTDIR}.tar.gz ${DISTDIR}

cp -a ${DISTDIR} ${DEBDIR}
GZIP=-9 tar czf ${DEBPKG}_${VERSION}.orig.tar.gz ${DEBDIR}

unix2dos `find ${DISTDIR} -type f -name \*.cl -or -name \*.list -or \
    -name \*.system -or -name Makefile -or -name ChangeLog -or \
    -name COPYRIGHT -or -name TODO -or -name README -or -name INSTALL -or \
    -name NEWS -or -name \*.sgml -or -name COPYING\* -or -name catalog`
zip -rq ${DISTDIR}.zip ${DISTDIR}

cp -a ${WORK_DIR}/debian ${DEBDIR}
rm -f ${DEBDIR}/debian/.cvsignore 
rm -rf ${DEBDIR}/debian/CVS

rm -rf ${DISTDIR} ${DEBDIR}

echo "Moving upstream archives to ${PACKAGE_DIR}"
mkdir -p /usr/local/src/Packages/${DEBPKG}
rm -f ${PACKAGE_DIR}/${DISTDIR}.zip ${PACKAGE_DIR}/${DEBPKG}_${VERSION}.orig.tar.gz
mv ${DISTDIR}.zip ${DEBPKG}_${VERSION}.orig.tar.gz ${DISTDIR}.tar.gz ${PACKAGE_DIR}

cd ${WORK_DIR}
exit 0