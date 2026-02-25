FROM python:3.14.0

COPY DiscordBot/requirements.txt .
RUN pip install -r requirements.txt

COPY DiscordBot/ .
RUN chmod +x /entrypoint.sh

EXPOSE 6969

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "main.py"]
