.PHONY: dist

dist: clean
	mkdir -p dist && \
	cp src/* dist && \
	cd dist &&\
	PYTHONUSERBASE=. pip3 install --user -r requirements.txt --force &&\
	mv lib/python/site-packages/* . &&\
	zip -r9 github_org_webhook.zip .

clean:
	rm -rf ./dist