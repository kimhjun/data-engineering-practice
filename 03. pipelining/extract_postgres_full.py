import psycopg2
import csv
import boto3
import configparser

parser = configparser.ConfigParser()
parser.read('pipeline.conf')
dbname = parser.get('postgres_config', 'database')
user = parser.get('postgres_config', 'username')
password = parser.get('postgres_config', 'password')
port = parser.get('postgres_config', 'port')
host = parser.get('postgres_config', 'host')

conn = psycopg2.connect(
    f"dbname={dbname} user={user} password={password} host={host} port={port}")

m_query = "SELECT * FROM Orders;"
local_filename = 'order_extract_pg.csv'

m_cursor = conn.cursor()
m_cursor.execute(m_query)
result = m_cursor.fetchall()

with open(local_filename, 'w') as fp:
    csv_w = csv.writer(fp, delimiter='|')
    csv_w.writerows(result)

fp.close()
m_cursor.close()
conn.close()

access_key = parser.get("aws_boto_credentials", "access_key")
secret_key = parser.get("aws_boto_credentials", "secret_key")
bucket_name = parser.get("aws_boto_credentials", "bucket_name")

s3 = boto3.client(
    's3',
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key)

s3_file = local_filename
s3.upload_file(local_filename, bucket_name, s3_file)
