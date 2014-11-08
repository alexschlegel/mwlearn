from django.conf.urls import patterns, url
from django.contrib.auth.decorators import login_required
from django.contrib.auth.views import login, logout
from django.views.generic.base import RedirectView

from mwlearnapp import views

urlpatterns = patterns('',
	#url(r'^$', views.Home.as_view(), name='home'),
	url(r'^$', RedirectView.as_view(url='/login/'), name='home'),
	#url(r'^login/$', views.AccountLogin.as_view(), name='account-login'),
	url(r'^login/$', login, {'template_name':'login.html'}, name='account-login'),
	url(r'^logout/$', logout, {'next_page': 'home'}, name='account-logout'),
	url(r'^experiment/$', login_required(views.Experiment.as_view()), name='experiment'),
	url(r'^data/$', login_required(views.data_view), name='data'),
)
