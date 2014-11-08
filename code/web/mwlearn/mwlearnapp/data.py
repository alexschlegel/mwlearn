"""SHORT DESCRIPTION

LONG DESCRIPTION

@author:    Alex Schlegel (schlegel@gmail.com).
created on: 2014-11-07

copyright 2014 Alex Schlegel (schlegel@gmail.com).  all rights reserved.
"""
import json
from pymongo import MongoClient

client = MongoClient()


def process_request(request):
	result = {'success': False}

	if 'action' in request and 'key' in request:
		result['action'] = request['action']
		result['key'] = request['key']

		if result['action'] == 'read':
			read(result)
		elif result['action'] == 'write' and 'value' in request:
			write(result, request['value'])
		elif result['action'] == 'archive' and 'value' in request:
			if 'id' in request:
				result['id'] = request['id']
			archive(result, request['value'])


def read(result):
	result['value'] = None
	result['status'] = 'nonexistent' #***
	result['success'] = True


def write(result, value):
	result['status'] = 'write'
	result['value'] = json.loads(value)
	#write to database***
	result['success'] = True


def archive(result, value):
	result['status'] = 'archive'
	result['value'] = json.loads(value)
	if 'id' in result:
		None
	else:
		None
	#archive to database***
	result['success'] = True
