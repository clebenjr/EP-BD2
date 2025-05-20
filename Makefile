make run:
	python app.py


make create_venv:
	virtualenv .venv

make activate_linux:
	source .venv/bin/activate

make activate_windows:
	.venv\Scripts\activate.bat

make if_windows_bug:
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser


make install:
	pip install -r requirements.txt
