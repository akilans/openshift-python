FROM python:latest

MAINTAINER Akilan "akilan_s@infosys.com"

# Copy the requirements file
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

# Install All dependencies 
RUN pip install -r requirements.txt

EXPOSE 8000

COPY . /app

CMD ["python", "app.py"]