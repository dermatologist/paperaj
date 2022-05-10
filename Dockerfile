FROM python:3.7

WORKDIR /workdir
COPY . .
RUN apt-get update && apt-get install -y pandoc pandoc-citeproc
RUN pip install -r requirements.txt
ENTRYPOINT [ "/workdir/article.sh" ]
