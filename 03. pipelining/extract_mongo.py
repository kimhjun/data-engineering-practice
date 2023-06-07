from pymongo import MongoClient
import csv
import boto3
import datetime
from datetime import timedelta
import configparser

parser = configparser.ConfigParser()
parser.read('pipeline.conf')
username = parser.get('mongo_config', 'username')
password = parser.get('mongo_config', 'password')

mongo_client = MongoClient(
    f'mongodb+srv://{username}:{password}@cluster0.pbxdm0g.mongodb.net/?retryWrites=true&w=majority')
mongo_db = mongo_client['mymongo1']
mongo_collection = mongo_db['mycollection1']

start_date = datetime.datetime.today() + timedelta(days=-1)
end_date = start_date + timedelta(days=1)

mongo_query = {
    "$and": [
    {"event_timestamp": {"$gte": start_date}}, 
    {"event_timestamp": {"$lt": end_date}}
    ]
}

event_docs = mongo_collection.find(mongo_query, batch_size=3000)

all_events = []

for doc in event_docs:
    event_id = str(doc.get("event_id", -1))
    event_timestamp = doc.get(
        "event_timestamp", None)
    event_name = doc.get("event_name", None)

    current_event = []
    current_event.append(event_id)
    current_event.append(event_timestamp)
    current_event.append(event_name)

    all_events.append(current_event)
print(all_events)
export_file = "export_file.csv"

with open(export_file, 'w') as fp:
    csv_w = csv.writer(fp, delimiter='|')
    csv_w.writerows(all_events)

fp.close()

access_key = parser.get("aws_boto_credentials", "access_key")
secret_key = parser.get("aws_boto_credentials", "secret_key")
bucket_name = parser.get("aws_boto_credentials", "bucket_name")

s3 = boto3.client('s3',
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key)

s3_file = export_file
s3.upload_file(export_file, bucket_name, s3_file)