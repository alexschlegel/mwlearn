from django.test import TestCase
from django.test.client import RequestFactory
from mwlearnapp import data


class DataTestCase(TestCase):
	def setUp(self):
		self.factory = RequestFactory()

	def read(self):
		request = self.factory.get('/data/?action=read&key=assemblage_trials_finished')
		request.user = 'alex'

		response = data.process_request(request)

