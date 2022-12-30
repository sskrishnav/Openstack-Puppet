#import time
#import os
import sys
sys.path.append("../../workspace/")
import paramiko
import config as castlight_config
import test as test



def castlight_testcase_get_uname(vm_ip):

    print "vm_ip is------------>:",vm_ip
    sshObj_network = test.create_ssh_object(vm_ip, \
                 castlight_config.image_user, castlight_config.\
                 image_pass)
    print sshObj_network    
    command_run_on_vm = "uname -a"
    output = test.run_cmd_on_server(sshObj_network, command_run_on_vm)
    print "output after running command on vm",output
    return output



def castlight_testcase_get_interfaces(vm_ip):


    sshObj_network = test.create_ssh_object(vm_ip, \
                 castlight_config.image_user, castlight_config.\
                 image_pass)

    command_run_on_vm = "ip a"
    output = test.run_cmd_on_server(sshObj_network, command_run_on_vm)
    print "output after running command on vm",output


