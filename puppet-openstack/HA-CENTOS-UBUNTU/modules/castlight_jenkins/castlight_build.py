import time
import conf.castlight_config as cl_config
from lib.castlight_wrapper import CASTLIGHT_WRAPPER


if __name__ == "__main__":
    # """
    try:
        cl_wrap = CASTLIGHT_WRAPPER()
        l_result = cl_wrap.launch_vm_with_floating_ip()
        if None in l_result.values():
            err_msg = ("Launch VM with Floating IP is failed with "
                       "details : %s\n" % l_result)
            print 70 * "-" + "\n" + err_msg + 70 * "-" + "\n"
            raise Exception(err_msg)
        print (70 * "*" + "\n" +
               "Launch VM with Floating IP is succeded with details : %s\n"
               % l_result + 70 * "*" + "\n")

        time.sleep(10)
        # raw_input("ENTER ANY KEY TO RUN TEST ON VM\n")
        script_result = cl_wrap.run_scripts_on_vm(l_result['public_ip'],
                                                  cl_config.image_user,
                                                  cl_config.image_pass,
                                                  cl_config.test_scripts_path,
                                                  cl_config.copy_path_in_vm)
        if not script_result or not isinstance(script_result, bool):
            err_msg = ("Script execution is failed and result is : %s"
                       % script_result)
            print 70 * "-" + "\n" + err_msg + 70 * "-" + "\n"
            raise Exception(err_msg)
        print (70 * "*" + "\n" +
               "All Scripts are executed successfully\n" +
               70 * "*" + "\n")

    except Exception as expt:
        print "ERROR : %s" % expt

    finally:
        time.sleep(10)
        # raw_input("ENTER ANY KEY TO DELETE VM\n")
        if isinstance(l_result, dict) and isinstance(l_result['vm_id'],
                                                     unicode):
            d_result = cl_wrap.delete_vm_with_floating_ip(
                            l_result['vm_id'],
                            l_result['floatingip_id'])
            if not d_result and isinstance(d_result, bool):
                err_msg = "Deletion of VM with Floating IP is failed\n"
                print 70 * "-" + "\n" + err_msg + 70 * "-" + "\n"
                sys.exit(0)
            print (70 * "*" + "\n" +
                   "Deletion of VM with Floating IP is succeded\n" +
                   70 * "*" + "\n")
    # """

    # cl_wrap.delete_vm_with_floating_ip("e8cf0e25-e328-46c6-98d2-686154ecccbb",
    #                                    "430adadf-19c1-4326-801e-f33dd87e6824")
    # cl_wrap.delete_vm_with_floating_ip("8980cdaf-13ec-446f-837d-e4dbe30de88e",
    #                                    "0ada6abc-dfd4-4048-81aa-d48f044c9df6")
