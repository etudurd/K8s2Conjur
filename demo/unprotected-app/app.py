import os
import psycopg2
import time
import sys

sys.stdout.reconfigure(line_buffering=True)

def connect():
    dbname = os.getenv("DB_NAME")
    user = os.getenv("DB_USERNAME")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST", "postgres")
    port = os.getenv("DB_PORT", "5432")

    while True:
        try:
            conn = psycopg2.connect(
                dbname=dbname,
                user=user,
                password=password,
                host=host,
                port=port
            )
            print(f"[SUCCESS] Connected to DB '{dbname}' as '{user}'")
            conn.close()
        except Exception as e:
            print(f"[FAILURE] Could not connect to DB: {e}")
        time.sleep(10)

if __name__ == "__main__":
    connect()
