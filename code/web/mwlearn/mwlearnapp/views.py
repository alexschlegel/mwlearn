from django.views.generic.base import TemplateView


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
