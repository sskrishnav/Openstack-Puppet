import os
import sys

controller_ip = "172.20.1.111"

admin_user_name = "svutukuri"
admin_password = "Prince1234-"
# admin_project_id = "ca1d10786fdc41698e276a8f22d98741"
admin_project_name = "admin"
admin_domain_id = "default"

net_name = "k_net1"
ext_nw_name = "ext-net"
flavor_name = "m1.tiny"
image_name = "cirros-0.3.4-x86_64"

image_console_log_expr = " login"
image_user = "cirros"
image_pass = "cubswin:)"
command_run_on_vm = "uname -a"

test_scripts_path = os.path.abspath(os.path.dirname(sys.argv[0])) +\
                    "/test_scripts"
copy_path_in_vm = "/home/" + image_user
