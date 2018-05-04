build:
	swift build -Xswiftc -DNOJSON

dump:
	bundle exec ridgepole -c database.yml --export --output Schemafile

dump_dev:
	bundle exec ridgepole -c .database.yml --export --output Schemafile