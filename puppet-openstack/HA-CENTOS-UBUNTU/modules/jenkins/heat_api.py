import time
import traceback
import datetime
import request
import json
import uuid
import sys
import ast
import yaml
import math
import config as config

class HEAT_LIB():

    def __init__(self):
        self.token = ""
        self.connection = request.OCRequest()
        self.hostIP     = ""

    def get_token(self,tenantName,userName,password):
        _url = "http://"+self.hostIP+":5000/v2.0/tokens"
        _headers = {"content-type":"application/json"}
        _tokenInfo = {"auth":
                       {"tenantName": tenantName,
                        "passwordCredentials":
                              {"username": userName,
                               "password": password
                               }
                        }
                    }

        _body=json.dumps(_tokenInfo)
        response=self.connection.request("POST", _url, _headers, _body)
        if response == None :
            return response
        if response.status not in  [200, 201, 202, 203, 204]:
            return response.status
        output=json.loads(response.data)
        tokenID=output['access']['token']['id']
        return tokenID


    def stack_list(self, tenantName):
        '''
        To get the list of created stacks
        arguments :
                tenantName : tenantName where stack created
        '''

        _tenantID = self.get_tenant_id(tenantName)

        _url="http://192.168.57.101:8004/v1/"+str(_tenantID)+"/stacks"
        _headers={ 'Content-type': 'application/json',
                  'x-auth-token':self.token }
        _body=None

        response = self.connection.request("GET", _url, _headers, _body)

        if response == None :
            return response

        if response.status not in [200, 201, 202, 203, 204]:
            return response.status
        output = json.loads(response.data)
        return output

    def get_tenant_id(self,tenantName) :
        _url="http://"+self.hostIP+":35357/v2.0/tenants"
        _headers={'x-auth-token':self.token}
        _body=None

        response=self.connection.request("GET", _url, _headers, _body)
        if response == None :
            return response
        if response.status not in  [200, 201, 202, 203, 204]:
            return response.status
        output=json.loads(response.data)

        _tenantID=None

        for tenant in output['tenants'] :
            if tenant['name']==tenantName :
                _tenantID=tenant['id']
                print "Tenant Name :",tenantName
                print "Tenant ID :",_tenantID
                return _tenantID
        return _tenantID


    def create_stack(self, tenantName, stackName, filePath, parameters = None):
        '''
        To create stack
        arguments :
                tenantName : tenantName where stack to be create
                stackName : name of the stack to create
                filePath : location of the template file     
                parameters : by default it is "None"
                             If template wants any parameters then it takes as a dictionary                    
                           ex: {'ServiceProvider' : providerName,
                                'Subnet_CIDR' : tenant_info['cidr']
                               }

        '''

        _tenantID=self.get_tenant_id(tenantName)

        _url="http://192.168.57.101:8004/v1/" + str(_tenantID) + "/stacks"
        _headers={ 'Content-type': 'application/json',
                  'x-auth-token':self.token }

        _jsonobj = filePath
        try:
            # open file stream
            myfd=open(_jsonobj, "r")
        except IOError, e:
            err="There was an error reading from '"+_jsonobj+"'\n"+str(e)
            print err
            sys.exit()

        mydict = {}
        # convert to python dict
        template_data = myfd.read()
        if template_data.startswith('{'):
            mydict['template'] = json.loads(template_data)
        else:
            mydict['template'] = yaml.load(template_data)
        mydict['stack_name'] = stackName
        if parameters is not None:
            mydict['parameters'] = parameters

        print "parameters are :",mydict
        date_time = mydict['template']['heat_template_version']
        #date_time = mydict[template[heat_template_version]]
        print date_time
        mydict['template']['heat_template_version'] = str(date_time)
        _body=json.dumps(mydict)
        #_body=str(mydict)
        # cose the file
        myfd.close()

        time.sleep(2)
        response=self.connection.request("POST", _url, _headers, _body)
        if response == None :
            return response
        if response.status not in [200, 201, 202, 203, 204]:
                return response.status

        print "----------->",response.data
        output=json.loads(response.data)
        return output['stack']['id']



    def stack_show(self, tenantName, stackName, _stackID):
        '''
        To get the details of stack
        arguments :
                tenantName : tenantName where stack created
                stackName : name of the stack created
        '''

        _tenantID = self.get_tenant_id(tenantName)

        if _stackID == None:
            print "No stack is exist with the name %s" % stackName
            return None

        _url="http://"+str(self.hostIP)+":8004/v1/"+str(_tenantID)+"/stacks/"+stackName+"/"+_stackID
        _headers={ 'Content-type': 'application/json',
                  'x-auth-token':self.token }
        _body=None

        response = self.connection.request("GET", _url, _headers, _body)

        if response == None :
            return response

        if response.status not in [200, 201, 202, 203, 204]:
            return response.status
        output = json.loads(response.data)
        return output


    def delete_stack(self, tenantName, stackName, _stackID):
        '''
        To delete stack
        arguments :
                tenantName : tenantName where stack created
                stackName : name of the stack to be delete
        '''

        _tenantID = self.get_tenant_id(tenantName)
        print "tenant id is:",_tenantID
        print "_stackID is:",_stackID
        if _stackID == None:
            print "No stack is exist with the name %s" % stackName
            return None
        print tenantName, stackName, _stackID
        print str(self.hostIP)
        _url="http://"+str(self.hostIP)+":8004/v1/"+str(_tenantID)+"/stacks/"+stackName+"/"+_stackID
        _headers={ 'Content-type': 'application/octet-stream',
                  'x-auth-token':self.token }
        _body=None

        response = self.connection.request("DELETE", _url, _headers, _body)

        if response == None :
            return response

        if response.status not in [200, 201, 202, 203, 204]:
            return response.status
        return True

