from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.managevms, name='managevms'),
    url(r'^managevms/', views.managevms, name='managevms'),
    url(r'^createvm/$', views.createvm, name='createvm'),
    url(r'^utilization/$', views.utilization, name='utilization'),
    url(r'^login/$', views.login, name='login'),
    url(r'^logout/$', views.logout, name='logout'),
    url(r'^getvmstatus/', views.getvmstatus, name='getvmstatus'),
]