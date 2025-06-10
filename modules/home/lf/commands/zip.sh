set -f
mkdir $1
cp -r $fx $1
zip -r $1.zip $1
rm -rf $1
