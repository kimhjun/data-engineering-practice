from pymongo import MongoClient
import datetime
import configparser

parser = configparser.ConfigParser()
parser.read('pipeline.conf')
username = parser.get('mongo_config', 'username')
password = parser.get('mongo_config', 'password')

mongo_client = MongoClient(f'mongodb+srv://{username}:{password}@cluster0.pbxdm0g.mongodb.net/?retryWrites=true&w=majority')

mongo_db = mongo_client['mymongo1']
mongo_collection = mongo_db['mycollection1']

event_1 = {
    "event_id": 1,
    "event_timestamp": datetime.datetime.today(),
    "event_name": 'signup'
}

event_2 = {
    "event_id": 2,
    "event_timestamp": datetime.datetime.today(),
    "event_name": 'pageview'
}

event_3 = {
    "event_id": 3,
    "event_timestamp": datetime.datetime.today(),
    "event_name": 'login'
}

mongo_collection.insert_one(event_1)
mongo_collection.insert_one(event_2)
mongo_collection.insert_one(event_3)