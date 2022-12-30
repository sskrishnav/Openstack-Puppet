import requests
import json
import logging
from openstack_dashboard import api
from datetime import date, timedelta
from hurry.filesize import size
from django.conf import settings
logger = logging.getLogger(__name__)


def create_instance(request, instance_params):
    """
    This method creates an instance with the given parameters

    """
    instance_name = instance_params['vmname']
    instance_role = instance_params['vmrole']
    instance_image = instance_params['vmimage']
    network_id = instance_params['network_id']

    flavor = get_flavor_from_name(request, instance_role)
    image = get_image(request, instance_image)

    tenant_id = request.user.tenant_id
    nics = []
    nics.append({"net-id": network_id, "v4-fixed-ip": ""});
    # network_list = api.neutron.network_list_for_tenant(request, tenant_id)
    # nics = []
    # if network_list:
    #         nics = [{"net-id": network.id, "v4-fixed-ip": ""}
    #                 for network in network_list]

    server = None
    try:
        server = api.nova.server_create(request, instance_name, image,flavor, 
                                None, None, None, nics=nics)
    except Exception :
        logger.error('create_instance:Unable to create VM')
    return server

def get_network_list(request):
    tenant_id = request.user.tenant_id
    network_list = api.neutron.network_list_for_tenant(request, tenant_id)
    return network_list


def get_instance_list(request):
    """
    This method returns the list of instances

    """
    try:

        instances,more = api.nova.server_list(request)
        #import pdb;pdb.set_trace()
    except Exception:
        instances = []
        logger.error('get_instance_list:Unable to retrieve instances.')
    if instances:
        try:
            api.network.servers_update_addresses(request, instances)
        except Exception:
            logger.debug('get_instance_list:Unable to retrieve IP addresses from Neutron.')
    
    flavor_list = api.nova.flavor_list(request)
    instances_list = []
    
    for instance in instances:
        #interfaces = api.nova.virtual_interfaces_list(request, instance.id)
        instances_map = {}
        
        flavor = get_flavor(flavor_list, instance.flavor['id'])
        instances_map['name'] = instance.name
        if instance.status == 'SHUTOFF':
            instances_map['state'] = 'SHUTDOWN'
        elif instance.status == 'BUILD':
            instances_map['state'] = 'BOOTING UP'
        elif instance.status == 'ACTIVE':
            instances_map['state'] = 'RUNNING'
        else:
            instances_map['state'] = instance.status

        instances_map['server_id'] = instance.id
        if flavor.disk < 1024:
            flavor_disk = str(flavor.disk) + "GB"
        else:
            flavor_disk = str(flavor.disk/1024) + "TB"
        if flavor.ram < 1024:
            flavor_ram = str(flavor.ram) + "MB"
        else:
            flavor_ram = str(flavor.ram/1024) + "GB"
        flavor_vcups = str(flavor.vcpus) + "CPU"
        instances_map['configuration'] = flavor_disk + " / " + flavor_ram + " / " + flavor_vcups
        #auth_info['server-id'] = instance['id']
        if len(instance.addresses.values()) != 0:
            if len(instance.addresses.values()[0]) >=2:
                instances_map['address_type'] = 'floating'
                #instances_map['address'] = instance.addresses.values()[0][0]['addr'] + "/" + instance.addresses.values()[0][1]['addr']
                instances_map['address'] = instance.addresses.values()[0][1]['addr']
            """else:
                instances_map['address_type'] = 'fixed'
                instances_map['address'] = instance.addresses.values()[0][0]['addr']"""
        instances_list.append(instances_map)
    return instances_list

def get_flavor(flavor_list, flavor_id):

    """
    This method returns the flavor for a given flavor_id

    """
    for flavor in flavor_list:
        if flavor.id == flavor_id:
            return flavor

def get_flavor_from_name(request, flavor_name):

    """
    This method returns the flavor for a given name

    """
    flavor_id = ""
    name = ""

    # Get the flavor name from the local settings
    if flavor_name == "Dev" :
        name = settings.FLAVOR_DEV
    elif flavor_name == "Web" :
        name = settings.FLAVOR_WEB
    elif flavor_name == "DB" :
        name = settings.FLAVOR_DB

    # Get the flavor id
    if name == "tiny" :
        flavor_id = "1"
    elif name == "small" :
        flavor_id = "2"
    elif name == "medium" :
        flavor_id = "3"
    elif name == "large" :
        flavor_id = "4"
    elif name == "xlarge" :
        flavor_id = "5"
    return api.nova.flavor_get(request, flavor_id)


def get_image(request, image_name):

    """
    This method returns the image for a given name, If not found returns None

    """
    images_list,has_more_date,has_prev_data = api.glance.image_list_detailed(request)
    
    if image_name == "Dev" :
        name = settings.IMAGE_NAME_DEV
    elif image_name == "Test" :
        name = settings.IMAGE_NAME_TEST
    elif image_name == "QA" :
        name = settings.IMAGE_NAME_QA
    elif image_name == "SignOff" :
        name = settings.IMAGE_NAME_SIGNOFF
    result_image = None
    for image in images_list:
        if image.name == name:
            result_image = image
            break
    return result_image

def get_instances_usage(request):

    """
    This method returns the usage metrics for all the instances

    """
    try:
        instances,more = api.nova.server_list(request)
        #import pdb;pdb.set_trace()
    except Exception:
        instances = []
        logger.error('get_instances_usage:Unable to retrieve instances.')

    instances_list = []
    for instance in instances:
        instances_map = {}
        query = make_query(resource_id=instance.id)
        try:
            meters = api.ceilometer.statistic_list(request, "cpu_util", query=query)
            instances_map['name'] = instance.name
            if len(meters) != 0:
                instances_map['cpu_util'] = round(meters[0].avg, 2)
            meters = api.ceilometer.statistic_list(request, "disk.usage", query)
            if len(meters) != 0:
                instances_map['disk_usage'] = size(meters[0].avg)
            meters = api.ceilometer.statistic_list(request, "memory.resident", query)
            if len(meters) != 0:
                instances_map['memory_usage'] = str(round(meters[0].avg, 2)) + 'MB'
            instances_list.append(instances_map)
        except Exception:
            logger.error('get_instances_usage:Error in ceilometer.statistic_list')
    return instances_list

def manage_instance(request, instance_id, action):
    """
    This method perform actions on given instance

    """
    if action == 'stop':
        api.nova.server_stop(request, instance_id)
    elif action == 'start':
        api.nova.server_start(request, instance_id)
    elif action == 'reset':
        api.nova.server_reboot(request, instance_id)
    elif action == 'delete':
        api.nova.server_delete(request, instance_id)
    elif action == 'associate':
        """try:
            instance = api.nova.server_get(request, instance_id)
            if len(instance.addresses.values()) != 0:
                if len(instance.addresses.values()[0]) >=2 and instance.addresses.values()[0][1]['OS-EXT-IPS:type'] == 'floating':
                    return {"error":"Instance already has associated with floating ip"}
                else:
                    floatingIpManager = api.neutron.FloatingIpManager(request)
                    #ports_list = floatingIpManager._target_ports_by_instance(instance_id)
                    port_id = floatingIpManager.get_target_id_by_instance(instance_id)
                    pool_list = floatingIpManager.list_pools()
                    floatingIp = floatingIpManager.allocate(pool_list[0].id)
                    floatingIpManager.associate(floatingIp.id, port_id)
                    return {"success":floatingIp.ip}
        except:
            return {"error":"Unable to associate floating ips"}"""
        floatingIpManager = api.neutron.FloatingIpManager(request)
        floatingIp_list = floatingIpManager.list()
        result_list = []
        result_list = get_free_floatingIps(request, floatingIp_list)
        if len(result_list) == 0:
            pool_list = floatingIpManager.list_pools()
            floatingIp = floatingIpManager.allocate(pool_list[0].id)
            result_list.append({'address':floatingIp.ip, 'id':floatingIp.id})
        return result_list

    elif action == 'disassociate':
        try:
            floatingIpManager = api.neutron.FloatingIpManager(request)
            floatingIp_list = floatingIpManager.list()
            for floatingIp in floatingIp_list:
                if floatingIp.instance_id == instance_id:
                    floatingIpManager.disassociate(floatingIp.id)
                    #floatingIpManager.release(floatingIp.id)
                    return {"success":"disassociated floating ip"}
        except:
            return {"error":"Unable to disassociate floating ip"}
        
def create_floatingip(request, instance_id, floating_ip_id):

    #instance_id = request.POST.get('server_id')
    #floating_ip_id = request.POST.get('floating_ip_id')
    try:
        
        instance = api.nova.server_get(request, instance_id)
        if len(instance.addresses.values()) != 0:
            if len(instance.addresses.values()[0]) >=2 and instance.addresses.values()[0][1]['OS-EXT-IPS:type'] == 'floating':
                return {"error":"Instance already has associated with floating ip"}
            else:
                floatingIpManager = api.neutron.FloatingIpManager(request)
                port_id = floatingIpManager.get_target_id_by_instance(instance_id)
                floatingIpManager.associate(floating_ip_id, port_id)
                return {"success":floating_ip_id}
    except:
        return {"error":"Unable to associate floating ips"}


def get_free_floatingIps(request, floatingIp_list):

    free_list = []

    instances,more = api.nova.server_list(request)
    map_flag = False

    for floatingIp in floatingIp_list:
        floatingIp_map = {}
        map_flag = False
        for instance in instances:
            if floatingIp.instance_id == instance.id:
                map_flag = True
        if map_flag is False:
            floatingIp_map['address'] = floatingIp.ip
            floatingIp_map['id'] = floatingIp.id
            free_list.append(floatingIp_map)
    return free_list

def get_vm_status(request, server_id):
    
    """
    This method returns status of a given instance

    """
    try:
        server = api.nova.server_get(request, server_id)
    except Exception:
        logger.error('get_vm_status:Unable to get the instance status' + server_id)
        return ""
    return server.status


def make_query(user_id=None, tenant_id=None, resource_id=None,
               user_ids=None, tenant_ids=None, resource_ids=None):
    """Returns query built from given parameters.

    This query can be then used for querying resources, meters and
    statistics.

    :Parameters:
      - `user_id`: user_id, has a priority over list of ids
      - `tenant_id`: tenant_id, has a priority over list of ids
      - `resource_id`: resource_id, has a priority over list of ids
      - `user_ids`: list of user_ids
      - `tenant_ids`: list of tenant_ids
      - `resource_ids`: list of resource_ids
    """
    user_ids = user_ids or []
    tenant_ids = tenant_ids or []
    resource_ids = resource_ids or []

    query = []
    if user_id:
        user_ids = [user_id]
    for u_id in user_ids:
        query.append({"field": "user_id", "op": "eq", "value": u_id})

    if tenant_id:
        tenant_ids = [tenant_id]
    for t_id in tenant_ids:
        query.append({"field": "project_id", "op": "eq", "value": t_id})

    if resource_id:
        resource_ids = [resource_id]
    for r_id in resource_ids:
        query.append({"field": "resource_id", "op": "eq", "value": r_id})

    query.append({"field": "timestamp", "op": "ge", "value": date.today()-timedelta(days=1)})
    query.append({"field": "timestamp", "op": "lt", "value": date.today()})
    return query
