FROM PYTHON

MAINTAINER Akilan "akilan_s@infosys.com"

# Copy the requirements file
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

# Install All dependencies 
RUN pip install -r requirements.txt

COPY . /app

ENTRYPOINT [ "python" ]

CMD [ "app.py" ]