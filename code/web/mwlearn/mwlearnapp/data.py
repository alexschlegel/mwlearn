"""SHORT DESCRIPTION

LONG DESCRIPTION

@author:    Alex Schlegel (schlegel@gmail.com).
created on: 2014-11-07

copyright 2014 Alex Schlegel (schlegel@gmail.com).  all rights reserved.
"""
import json
import time
from pymongo import MongoClient


client = MongoClient()
db = client.mwlearn
training_data = db.training_data
archive_data = db.archive_data


def process_request(request):
	result = {'success': False}

	if request.method == 'GET':
		data = request.GET
	elif request.method == 'POST':
		data = request.POST
	else:
		return result

	user = request.user.username

	if 'action' in data and 'key' in data:
		result['action'] = data['action']
		result['key'] = data['key']

		if result['action'] == 'read':
			read(user, result)
		elif result['action'] == 'write' and 'value' in data:
			value = json.loads(data['value'])
			write(user, result, value)
		elif result['action'] == 'archive' and 'value' in data:
			archive_time = data['time'] if 'time' in data else None
			value = json.loads(data['value'])
			archive(user, result, value, archive_time)

	return result


def read(user, result):
	key = result['key']

	data = training_data.find_one({'user': user}, {key: True})

	if not (data is None) and key in data:
		result['status'] = 'read'
		result['value'] = data[key]
	else:
		result['status'] = 'nonexistent'
		result['value'] = None

	result['success'] = True


def write(user, result, value):
	key = result['key']

	training_data.update({'user': user}, {"$set": {key: value}}, upsert=True)

	result['value'] = value
	result['status'] = 'write'
	result['success'] = True


def archive(user, result, value, archive_time=None):
	key = result['key']

	update_time = int(round(time.time()*1000))
	if archive_time is None:
		archive_time = update_time
	else:
		archive_time = int(archive_time)

	query = {'user': user, 'time': archive_time}
	data = {
		'user': user,
		'key': key,
		'value': value,
		'time': archive_time,
		'updated': update_time,
	}

	archive_data.update(query, data, upsert=True)

	result['time'] = archive_time
	result['value'] = value
	result['status'] = 'archive'
	result['success'] = True
