import json
import time
from urllib3 import PoolManager


class CLRequest(object):

    def __init__(self):
        self._pool = PoolManager(num_pools=10)

    def request(self, method, url, headers, body):
        response = None
        conn = self._pool
        print "Method : %s\nURL : %s\nHeaders : %s" %\
                  (method, url, headers)
        retry = 10

        while True:
            try:
                response = conn.urlopen(method, url, body=body,
                                        headers=headers,
                                        release_conn=True)
            except Exception, err:
                err_msg = ("Failed to send HTTP request for method :: %s,"\
                           " URL ::  %s, Error :: %s" %\
                           (method, url, err))
                print err_msg
                return None
            try:
                response.release_conn()
            except Exception, err:
                err_msg =\
                    ("Failed to release connection from urllib while getting"
                       " response for request with method :: %s, URL :: %s,"
                       " Error :: %s" % (method, url, err))
                print err_msg
                #return None

            if response is None:
                print "No response from the server for method: %s"\
                          " and url: %s.\nRetrying once more.\n" %\
                          (method, url) + 80 * "*"
                if retry == 0:
                    return None
                time.sleep(5)
                retry -= 1
                continue

            if response.status not in [200, 201, 202, 203, 204]:
                try:
                    print "Error while processing the request: %s "\
                            "Response status: %s."\
                            "\nResponse data: %s "\
                            "\nNow retrying once more...." %\
                            (url, response.status,\
                             json.loads(response.data))
                except Exception, err:
                    err = ("Failed to get JSON object from dictionary format."
                           " response data :: %s Error :: %s"
                           % (response.data, err))
                    print err

                if method == "GET":
                    if retry == 0:
                        print "Several times the GET request is failing."\
                        " So exiting."
                        break
                    time.sleep(5)
                    retry -= 1
                    continue
                else:
                    break  # return response
            else:
                break  # return response

        return response

    def process_request(self, method, request_url, headers, data):
        """ Perform the REST API call.

        :param method: Type of method (GET/POST/PUT/DELETE)
        :param request_url: Absolute URL of the REST call
        :param headers: HTML headers
        :param data: HTML body

        :return: On Failure: None
                On success:
                  for method = DELETE: HTTP response
                  for Other methods: HTTP response Data

        """
        retry_count = 3
        while retry_count:
            try:
                conn = self.conn_pool
                response = conn.urlopen(method, request_url, body=data,
                                        headers=headers, release_conn=True)
            except Exception, err:
                err = ("Failed to send HTTP request for method :: %s, URL :: "\
                       "%s, Error :: %s" % (method, request_url, err))
                print err
                return None

            try:
                response.release_conn()
            except Exception, err:
                err = ("Failed to release connection from urllib while getting"
                       " response for request with method :: %s, URL :: %s,"
                       " Error :: %s" % (method, request_url, err))
                print err
                return None

            # check whether the request is successful or not.
            if response == None:
                print "No response from the server."
                return None

            if method != 'GET':
                if response.status not in [200, 201, 202, 203, 204]:
                    print "Error while processing the request."\
                        " Response status: %s\n Response Data: %s" %\
                        (response.status, json.loads(response.data))
                    return None

                if method == 'DELETE':
                    return response

                return json.loads(response.data)

            else:
                try:
                    # Retry the GET request if it fails
                    # due to client error (4xx)
                    print response.status
                    print response.data
                    if response.status > 399 and response.status < 500:
                        print "Error while processing the request: %s "\
                            "due to Client ERROR. Response status: %s."\
                            "\nResponse data: %s "\
                            "\nNow retrying once more...." %\
                            (request_url, response.status,\
                             json.loads(response.data))

                        time.sleep(5)
                        retry_count -= 1
                        if retry_count == 0:
                            print "Several times the GET request"\
                            " is failing. So exiting."
                        continue

                    elif response.status not in [200, 201, 202, 203, 204]:
                        print "Error while processing the request."\
                        " Response status: %s\n Response Data: %s" %\
                        (response.status, json.loads(response.data))
                        return None

                    return json.loads(response.data)

                except ValueError:
                    err = response.data
                    print err
                    return None
                except Exception, err:
                    err = ("Failed to get JSON object from dictionary format."
                           " response data :: %s Error :: %s"
                           % (response.data, err))
                    return None

