FROM python:latest

MAINTAINER Akilan "akilan_s@infosys.com"

# Copy the requirements file
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

# Install All dependencies 
RUN pip install -r requirements.txt

EXPOSE 8000

COPY . /app

USER root

RUN echo appuser:x:999:9999:USER_NAME:/home/users/USER_NAME:/bin/bash >> /etc/passwd

USER appuser

CMD ["python", "app.py"]