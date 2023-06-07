import boto3
import configparser
import psycopg2

parser = configparser.ConfigParser()
parser.read('pipeline.conf')
dbname = parser.get('aws_creds', 'database')
user = parser.get('aws_creds', 'username')
password = parser.get('aws_creds', 'password')
host = parser.get('aws_creds', 'host')
port = parser.get('aws_creds', 'port')

rs_conn = psycopg2.connect(
    f"dbname={dbname} user={user} password={password} host={host} port={port}"
)

account_id = parser.get('aws_boto_credentials', 'account_id')
iam_role = parser.get('aws_creds', 'iam_role')
bucket_name = parser.get('aws_boto_credentials', 'bucket_name')

sql = "TRUNCATE public.Orders;"
cur = rs_conn.cursor()
cur.execute(sql)
cur.close()
rs_conn.commit()

file_path = f"s3://{bucket_name}/order_extract.csv"
role_string = f"arn:aws:iam::{account_id}:role/{iam_role}"

sql = f"COPY public.Orders from '{file_path}' iam_role '{role_string}'"

cur = rs_conn.cursor()
cur.execute(sql)

cur.close()
rs_conn.commit()

rs_conn.close()