import os
import time
import psycopg2

try:
    conn = psycopg2.connect(os.getenv('DATABASE_URL'))
    conn.close()
    exit(0)
except psycopg2.OperationalError:
    exit(1)
