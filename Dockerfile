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

RUN groupadd -g 9999 appuser && useradd -r -u 9999 -g appuser appuser

USER appuser

CMD ["python", "app.py"]