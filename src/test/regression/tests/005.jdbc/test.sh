#! /bin/sh -x
#-------------------------------------------------------------------
# test script for jdbc test
#
source $TESTLIBS
TESTDIR=testdir
PSQL=$PGBIN/psql
export CLASSPATH=.:$JDBC_DRIVER

for mode in s r n
do
	rm -fr $TESTDIR
	mkdir $TESTDIR
	cd $TESTDIR

# create test environment
	echo -n "creating test environment..."
	sh $PGPOOL_SETUP -m $mode -n 2 || exit 1
	echo "done."

	source ./bashrc.ports

# create Java property file
	cat > pgpool.properties <<EOF
pgpooltest.host=localhost
pgpooltest.port=$PGPOOL_PORT
pgpooltest.user=$USER
pgpooltest.password=
pgpooltest.dbname=test
pgpooltest.options=
pgpooltest.tests=autocommit batch column lock select update insert
EOF
	cp ../*.java .
	cp ../*.sql .
	cp ../run.sh .
	cp -r ../expected .
	cp ../expected.txt .

	./startall

	export PGPORT=$PGPOOL_PORT

	wait_for_pgpool_startup

	sh run.sh > result.txt 2>&1
	cmp result.txt expected.txt || (./shutdown all;exit 1)

	./shutdownall

	cd ..

done

exit 0
