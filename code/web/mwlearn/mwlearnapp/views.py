import json

from django.http import HttpResponse
from django.views.generic.base import TemplateView
from django.contrib.auth.decorators import login_required

from mwlearnapp import data

@login_required
def data_view(request):
	result = data.process_request(request)
	return HttpResponse(json.dumps(result), mimetype='application/json')


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
