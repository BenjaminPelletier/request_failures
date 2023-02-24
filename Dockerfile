FROM python:3.9

RUN apt-get update && apt-get install openssl && apt-get install ca-certificates

RUN mkdir -p /app
COPY ./requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

RUN rm -rf __pycache__

COPY ./main.py /app/main.py
WORKDIR /app

ENV PYTHONPATH /app
ENTRYPOINT []
