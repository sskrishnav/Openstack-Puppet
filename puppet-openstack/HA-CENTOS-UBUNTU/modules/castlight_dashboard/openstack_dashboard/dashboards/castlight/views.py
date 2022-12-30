from django.shortcuts import render
from django.http import HttpResponseRedirect, HttpResponse, Http404
from django.core.urlresolvers import reverse
from django.contrib.auth import login
from django.contrib.auth.forms import AuthenticationForm
from django.utils import functional
from django.contrib.auth import views as django_auth_views
from openstack_auth import forms
from openstack_auth import user as auth_user
from openstack_auth import views as openstack_auth_views
from django.contrib.auth.decorators import login_required
from django.contrib import auth
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
import logging
import time
import json
import django
from . import helpers

logger = logging.getLogger(__name__)

@login_required
def managevms(request):

    if request.method == 'POST' and request.is_ajax:
        instance_id = request.POST.get('server_id')
        floating_ip_id = request.POST.get('floating_ip_id')
        status = helpers.create_floatingip(request, instance_id, floating_ip_id)
        return HttpResponse(json.dumps(status))
        #return HttpResponseRedirect(reverse('managevms'))
    else:
        if request.GET.get('action','') :
            action = request.GET.get('action','')
            server_id = request.GET.get('server_id','')

            floatingIp = helpers.manage_instance(request, server_id, action)
            if floatingIp is not None:
                return HttpResponse(json.dumps({'floatingIp_list':floatingIp}))
            else:
                #return HttpResponseRedirect(reverse('managevms'))
                return HttpResponse(json.dumps('success'))
        else: 
            instances_list = helpers.get_instance_list(request)
            paginator = Paginator(instances_list, 5)
            page = request.GET.get('page')
            try:
                instances = paginator.page(page)
            except PageNotAnInteger:
                instances = paginator.page(1)
            except EmptyPage:
                instances = paginator.page(paginator.num_pages)
            return render(request, 'castlight/managevms.html', 
                    {'instances_list':instances,'active_tab':'manage_vms' })

@login_required
def createvm(request):
    if request.method == 'POST':
        #response = helpers.get_auth_token()
        instance_params = {}
        instance_params['vmname'] = request.POST.get('vmname')
        instance_params['vmrole'] = request.POST.get('vmrole')
        instance_params['vmimage'] = request.POST.get('vmimage')
        instance_params['network_id'] = request.POST.get('network_id')

        created_instance_info = helpers.create_instance(request, instance_params)
        if created_instance_info is not None:
            return HttpResponseRedirect(reverse('managevms'))
        else:
            raise Http404("Unable to create VM")
    else:
        network_list = helpers.get_network_list(request)
        #import pdb;pdb.set_trace()
        return render(request, 'castlight/createvm.html',
                             {'active_tab':'create_vms','network_list':network_list })

@login_required
def utilization(request):
    instances_list = helpers.get_instances_usage(request)
    paginator = Paginator(instances_list,5)
    page = request.GET.get('page')
    try:
        instances = paginator.page(page)
    except PageNotAnInteger:
        instances = paginator.page(1)
    except EmptyPage:
        instances = paginator.page(paginator.num_pages)

    return render(request, 'castlight/utilization.html', 
                                {'instances_list':instances, 'active_tab':'utilization'})

def getvmstatus(request):
    server_id = request.GET.get('server_id','')
    status = helpers.get_vm_status(request, server_id)
    return HttpResponse(status)

def login(request, template_name=None, extra_context=None, **kwargs):

    nextpage = request.GET.get('next', reverse('managevms'))
    template_name = 'castlight/login.html'
    
    if not request.is_ajax():
        if (request.user.is_authenticated() and
                auth.REDIRECT_FIELD_NAME not in request.GET and
                auth.REDIRECT_FIELD_NAME not in request.POST):
            return HttpResponseRedirect(nextpage)

    if request.method == "POST":
        
        if django.VERSION >= (1, 6):
            form = functional.curry(forms.Login)
        else:
            form = functional.curry(forms.Login, request)
        if extra_context is None:
            #auth.REDIRECT_FIELD_NAME = reverse('managevms')
            extra_context = {'redirect_field_name': auth.REDIRECT_FIELD_NAME}
        res = django_auth_views.login(request, template_name=template_name,
                                  authentication_form=form,
                                  extra_context=extra_context,
                                  **kwargs)
        #import pdb;pdb.set_trace()
        if request.user.is_authenticated():
            auth_user.set_session_from_user(request, request.user)
            return HttpResponseRedirect(nextpage);
        else:
            return render(request, 'castlight/login.html',{'auth_form': form,
                'title': 'User Login','header_css':'col-md-12',
                'error_message': 'Invalid Credentials',})
            
    else:
        form = functional.curry(forms.Login)
        return render(request, 'castlight/login.html',{'auth_form': form,
        'title': 'User Login','header_css':'col-md-12',
        'next': nextpage,})
    #import pdb;pdb.set_trace()

def logout(request, login_url=None, **kwargs):
    """Logs out the user if he is logged in. Then redirects to the log-in page.

    :param login_url:
        Once logged out, defines the URL where to redirect after login

    :param kwargs:
        see django.contrib.auth.views.logout_then_login extra parameters.

    """
    return django_auth_views.logout_then_login(request, login_url=reverse(login),
                                               **kwargs)
    
    
