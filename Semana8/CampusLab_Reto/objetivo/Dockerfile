FROM python:3.12-alpine
WORKDIR /app
COPY app.py /app/app.py
USER 65534:65534
ENV PYTHONUNBUFFERED=1
EXPOSE 8000
CMD ["python", "-u", "/app/app.py"]
