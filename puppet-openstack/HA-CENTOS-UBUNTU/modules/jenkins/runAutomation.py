import sys
sys.path.append("pwd")
import config as castlight_config
import test_cases.castlight_testcase_uname as testcase
import test as test
from heat_api import HEAT_LIB




heat = HEAT_LIB()
heat.hostIP = castlight_config.controller_ip
token = heat.get_token(castlight_config.admin_user, \
            castlight_config.admin_user, castlight_config.admin_pass)

print "token id is ----->",token
vm_ip, stack_id = test.get_vm_ip(token)
file = open('testcaseId.txt', 'r')
for line in file.readlines():
    name = str(line).rstrip('\n')
    output = "testcase."+name+"(vm_ip)"
    print output
    eval(output)

#stack_id = "e3fb04a6-97dd-4a94-a791-f29193a3cc78"
#token = "ccff1867858e4b70a7d08a135abe6199"
print "---------------------------------------->"
print token, stack_id
print test.delete_stack(token, stack_id)


    


