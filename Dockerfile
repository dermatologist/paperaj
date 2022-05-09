FROM python:3.7

COPY . .
RUN apt-get update && apt-get install -y pandoc
RUN pip install -r requirements.txt
ENTRYPOINT [ "/article.sh" ]