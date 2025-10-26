FROM python:3.14.0

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 6969

CMD ["python", "main.py"]
