from django.conf.urls import patterns, url
from django.contrib.auth.views import logout, login

from mwlearnapp import views

urlpatterns = patterns('',
	url(r'^$', views.Home.as_view(), name='home'),
	url(r'^experiment/$', views.Experiment.as_view(), name='home'),
)
