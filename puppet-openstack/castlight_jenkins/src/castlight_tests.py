import sys
import conf.castlight_config as cl_config
from lib.castlight_wrapper import CASTLIGHT_WRAPPER
sys.path.append("../")


cl_wrap = CASTLIGHT_WRAPPER()


def castlight_testcase_get_uname(vm_ip):
    print "Executing testcase castlight_testcase_get_uname"
    print 47*"*"
    ssh_obj = cl_wrap.create_ssh_object(vm_ip, cl_config.image_user,
                                        cl_config.image_pass)
    command = "uname -a"
    output = cl_wrap.run_cmd_on_server(ssh_obj, command)
    print "Output after running command on vm : %s\n" % output
    return output


def castlight_testcase_get_interfaces(vm_ip):
    print "Executing testcase castlight_testcase_get_interfaces"
    print 52*"="
    ssh_obj = cl_wrap.create_ssh_object(vm_ip, cl_config.image_user,
                                        cl_config.image_pass)

    command = "ip a"
    output = cl_wrap.run_cmd_on_server(ssh_obj, command)
    print "output after running command on vm is %s\n" % output
