juypter:
	@cd notebooks; PYTHONPATH=".." jupyter notebook api.ipynb

setup:
	python3 -m venv ./venv

env:
	#Show information about environment
	which python3
	python3 --version
	which pytest
	which pylint

lint:
	hadolint Dockerfile
	pylint --load-plugins pylint_flask --disable=R,C flask_app/*.py nlib csvcli

lint-docker:
	hadolint -V Dockerfile	

validate-circleci:
	# See https://circleci.com/docs/2.0/local-cli/#processing-a-config
	circleci config process .circleci/config.yml

run-circleci-local:
	# See https://circleci.com/docs/2.0/local-cli/#running-a-job
	circleci local execute build

lint-circleci:                                                              
	pylint --output-format=parseable --load-plugins pylint_flask --disable=R,C flask_app/*.py nlib csvcli > $$CIRCLE_ARTIFACTS/pylint.html  

test-circleci:
	@cd tests; pytest -vv --cov-report html:$$CIRCLE_ARTIFACTS --cov=web --cov=nlib test_*.py  

test:
	@cd tests; pytest -vv --cov-report term-missing --cov=web --cov=nlib test_*.py

upgrade-pip:
	pip install --upgrade pip

install:
	pip install -r requirements.txt 

validate-csv:
	#Binary found here:  https://github.com/Clever/csvlint
	csvlint ext/input.csv

start-api:
	#sets PYTHONPATH to directory above, would do differently in production
	cd flask_app && PYTHONPATH=".." python web.py

benchmark-web-sum:
	#very simple benchmark of api on sum operations
	ab -n 1000 -c 100 -T 'application/json' -u ext/input_base64.txt http://0.0.0.0:5001/api/npsum\?column=count\&group_by=last_name

profile:
	python3 -m cProfile -s cumtime ./csvcli.py cvsops --file ext/input.csv --groupby last_name --applyname count --func npmedian | less

all: install lint test
