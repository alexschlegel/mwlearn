import json

from django.http import HttpResponse
from django.views.generic.base import TemplateView
from django.contrib.auth.views import logout, login

from mwlearnapp import data


def data_view(request):
	if request.method=='GET':
		result = data.process_request(request.GET)
		return HttpResponse(json.dumps(result), mimetype='application/json')
	else:
		return 'hi'


class Home(TemplateView):
	template_name = "index.html"

	def get_context_data(self, **kwargs):
		context = super(Home, self).get_context_data(**kwargs)
		return context


class Experiment(TemplateView):
	template_name = "experiment.html"

	def get_context_data(self, **kwargs):
		context = super(Experiment, self).get_context_data(**kwargs)
		return context


class AccountLogin(TemplateView):
	template_name = "login.html"

	def get_context_data(self, **kwargs):
		context = super(AccountLogin, self).get_context_data(**kwargs)
		return context
