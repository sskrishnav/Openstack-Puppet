import os
import conf.castlight_config as cl_config
from lib.castlight_lib import CASTLIGHT_LIB
import sys
import paramiko
import pexpect
import time
import datetime
sys.path.append("../")


class CASTLIGHT_WRAPPER():
    def __init__(self):
        self.cl_lib = CASTLIGHT_LIB()
        self.cl_lib.host_ip = cl_config.controller_ip
        self.cl_lib.project_info['domain_id'] = cl_config.admin_domain_id
        self.cl_lib.project_info['project_name'] = cl_config.admin_project_name
        self.cl_lib.project_info['user_name'] = cl_config.admin_user_name
        self.cl_lib.project_info['password'] = cl_config.admin_password
        self.cl_lib.project_info['token'] = \
            self.cl_lib.get_v3_token(
            self.cl_lib.host_ip,
            self.cl_lib.project_info['domain_id'],
            self.cl_lib.project_info['project_name'],
            self.cl_lib.project_info['user_name'],
            self.cl_lib.project_info['password'])
        self.cl_lib.project_info['project_id'] = \
            str(self.cl_lib.get_keystone_v3_project_id(
                cl_config.admin_project_name))
        print ("The current project details are : %s\n"
               % self.cl_lib.project_info)
        return

    def create_ssh_object(self, host_ip, username, password):
        try:
            for retry in range(0, 3):
                print ("Trying for %s time" % (int(retry)+1))
                try:
                    print ("SSH object for host : %s, username : %s, "
                           "password : %s" % (host_ip, username, password))
                    ssh = paramiko.SSHClient()
                    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                    ssh.connect(host_ip, username=username,
                                password=password, timeout=60)
                    print "Creation of ssh object for %s is succeded" % host_ip
                    return ssh
                except Exception as ex:
                    print "We had an authentication exception!%s \n" % ex
                    # shell = None

        except Exception as ex:
            print "We had an authentication exception!\n", ex
            # shell = None

    def run_cmd_on_server(self, ssh_obj, command):
        print "Executing : %s" % command
        stdin, stdout, stderr = ssh_obj.exec_command(command)
        stdin.flush()
        data = stdout.read()
        return data.rstrip(os.linesep)

    # For SCP operation to a remote machine
    def scp_operation(self, user_name, password, ip_address,
                      source, destination=""):
        try:
            scp_newkey = 'Are you sure you want to continue connecting'
            if destination == "":
                scp_cmd = "scp -r " + source + " " + \
                    user_name + "@" + ip_address + ":/home/" + user_name
            else:
                scp_cmd = "scp -r " + source + " " + user_name + \
                    "@" + ip_address + ":" + destination
            print "Running scp command is : %s " % scp_cmd
            p = pexpect.spawn(scp_cmd)
            i = p.expect([scp_newkey, 'password:', pexpect.EOF], timeout=200)
            if i == 0:
                p.sendline('yes')
                time.sleep(5)
                i = p.expect([scp_newkey, 'password:', pexpect.EOF],
                             timeout=200)
            if i == 1:
                p.sendline(password)
                time.sleep(5)
                p.expect(pexpect.EOF)
            elif i == 2:
                pass
            return p.before
        except Exception as e:
            print "Scp operation failed due to %s" % e

    def launch_vm_with_floating_ip(self):
        result = {}
        result['vm_id'] = None
        result['floatingip_id'] = None
        result['public_ip'] = None
        result['private_ip'] = None
        server_name = "k_vm_" + str(datetime.datetime.now())
        image_console_log_expr = cl_config.image_console_log_expr
        vm = self.cl_lib.create_server(cl_config.image_name,
                                       cl_config.flavor_name,
                                       cl_config.net_name,
                                       server_name,
                                       image_console_log_expr)
        if not isinstance(vm['id'], unicode):
            print "VM Creation failed with reason : %s\n" % vm['status']
            return result
        elif vm['status'] != True:
            print ("VM Created with ID : %s. But not in ACTIVE state\n"
                   % vm['id'])
            result['vm_id'] = vm['id']
            return result
        print "VM Created with ID : %s\n" % vm['id']
        result['vm_id'] = vm['id']

        floatingip_id = self.cl_lib.create_floating_ip(cl_config.ext_nw_name)
        if not isinstance(floatingip_id, unicode):
            print ("Creation of floating ip is failed with reason : %s\n"
                   % floatingip_id)
            return result
        print "Floating Ip ID : %s\n" % floatingip_id
        result['floatingip_id'] = floatingip_id

        net_id = self.cl_lib.get_net_id(cl_config.net_name)
        if not isinstance(net_id, unicode):
            print "Get Net id is failed with a reason : %s\n" % net_id
            return result
        print "Net ID : %s\n" % net_id

        port_details = self.cl_lib.get_specific_port_by_server_id(net_id,
                                                                  vm['id'])
        if not isinstance(port_details, dict):
            print "Get Port ID failed with reason : %s\n" % port_details
            return result
        port_id = port_details["id"]
        print "Port ID : %s\n" % port_id

        fl_output = self.cl_lib.associate_floating_ip(floatingip_id, port_id)
        if not fl_output and not isinstance(fl_output, bool):
            print ("Association of floating ip is failed with reason : %s\n"
                   % fl_output)
            return result
        print "Floating Ip association done successfully\n"

        floatingip_ip = self.cl_lib.get_floating_ip_by_port_id(port_id)
        if not isinstance(floatingip_ip, unicode):
            print ("Get floating ip from port ID is failed with reason : %s\n"
                   % floatingip_ip)
            return result
        print "Floating Ip : %s\n" % floatingip_ip
        result['public_ip'] = floatingip_ip

        vm_ips = self.cl_lib.get_server_ip(vm['id'])
        if not isinstance(vm_ips, list):
            print "Get VM IP's are failed with reason : %s\n" % vm_ips
            return result
        print "IP's of VM : %s\n" % vm_ips
        result['private_ip'] = vm_ips

        return result

    def delete_vm_with_floating_ip(self, vm_id, floatingip_id=""):
        print "Deletion started"
        if floatingip_id:
            fl_output = self.cl_lib.disassociate_floating_ip(floatingip_id)
            if not fl_output and not isinstance(fl_output, bool):
                print ("Disassociation of floating ip is failed with reason : "
                       "%s\n" % fl_output)
                return
            print "Floating Ip disassociation done successfully\n"

            fl_output = self.cl_lib.delete_floating_ip(floatingip_id)
            if not fl_output and not isinstance(fl_output, bool):
                print ("Deletion of floating ip is failed with reason : %s\n"
                       % fl_output)
                return
            print "Floating Ip deletion is done successfully\n"

        result = self.cl_lib.delete_server(vm_id)
        if not result:
            print "Delete server failes with reason %s\n" % result
            return
        print "Delete server with Id %s is succeded\n" % vm_id

    def run_scripts_on_vm(self, vm_ip, vm_username, vm_password,
                          scripts_path, path_in_vm):

        ssh_obj = self.create_ssh_object(vm_ip, vm_username, vm_password)
        if ssh_obj is None:
            err_msg = ("Creation of ssh object is failed with reason : %s"
                       % ssh_obj)
            print err_msg
            return err_msg
        else:
            print "Creation SSH object is succeded"

        command = cl_config.command_run_on_vm
        result = self.run_cmd_on_server(ssh_obj, command)
        print ("Result of the command : %s is : %s \n" % (command, result))

        scp_result = self.scp_operation(vm_username, vm_password, vm_ip,
                                        scripts_path, path_in_vm)
        if not scp_result:
            err_msg = "SCP Operation is failed with reason : %s\n" % scp_result
            print err_msg
            return err_msg
        print "Copy of test scripts is succeded\n"

        command = "ls" + " " + path_in_vm + "/" +\
                  os.path.basename(scripts_path)
        result = self.run_cmd_on_server(ssh_obj, command)
        print ("Result of the command : %s is : \n%s\n" % (command, result))
        for script in result.split("\n"):
            print script
            command = "cd" + " " + path_in_vm + "/" + \
                      os.path.basename(scripts_path) + ";" +\
                      "sh" + " " + script
            result = self.run_cmd_on_server(ssh_obj, command)
            print ("\nResult of the command : %s is : \n%s \n"
                   % (command, result))

        return True
