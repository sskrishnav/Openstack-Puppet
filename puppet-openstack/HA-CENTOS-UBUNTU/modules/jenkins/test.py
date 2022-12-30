import commands
import sys
import paramiko
import time
import os
import copy
import json
import datetime
sys.path.append("pwd")
import config as castlight_config
from heat_api import HEAT_LIB

def create_ssh_object(hostIP, user, passwd):
    print "In create_ssh_object function"
    print hostIP, user, passwd
    try:
        for i in range(0,1):
            try:
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.connect(hostIP, username=user, password=passwd, timeout=60)
                return ssh
            except Exception as e:
                print "We had an authentication exception!", e
                shell = None

    except Exception as e:
        print "We had an authentication exception!", e
        shell = None

# Runs system commands on remote machine


def run_cmd_on_server(sshObj, command):
    print "In run_cmd_on_server function:"
    print "command is:",command
 
    stdin, stdout, stderr = sshObj.exec_command(command)
    stdin.flush()
    data = stdout.read()
    print data    
    return data.rstrip(os.linesep)



def get_vm_ip(token):

    heat = HEAT_LIB()
    heat.hostIP = castlight_config.controller_ip
    print  "############# keystone get token  ###############"
    heat.token = token


    print  "############# heat stack create ###############"
    parameters = {'ImageID' : castlight_config.image_name, 'NetID' : castlight_config.net_id, \
              'ext_nw_id' : castlight_config.ext_nw_id, 'sub_netID' : castlight_config.sub_netID }
    stack_id = heat.create_stack(castlight_config.admin_user, \
               castlight_config.vm_name, castlight_config.path, parameters)
    print "stack details",stack_id

    time.sleep(100)

    print  "############# heat stack show  ###############"
    stack_details = heat.stack_show(castlight_config.admin_user, \
                    castlight_config.vm_name, str(stack_id))
    print stack_details

    vm_ip = str(stack_details['stack']['outputs'][0]['output_value'])
    print "vm_ip is:",vm_ip
    return vm_ip, stack_id


def delete_stack(token, stack_id):

    heat = HEAT_LIB()
    heat.hostIP = castlight_config.controller_ip
    print  "############# keystone get token  ###############"
    heat.token = token
    stack_details = heat.delete_stack(castlight_config.admin_user, \
                    castlight_config.vm_name, str(stack_id))
    if stack_details:
       print "stack deleted successfully"
    else:
       print "stack not deleted successfully"
