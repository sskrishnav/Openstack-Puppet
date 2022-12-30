
$( document ).ready(function() {

    $('.fieldWrapper').find('label[for=id_region]').hide()
    registerVMAction();
    registerVMCreate();
    registerVMBooting();
   
    $('.nav.nav-tabs > li').on('click', function(e) {
      $('.nav.nav-tabs > li').removeClass('active');
      $(this).addClass('active');

      var target = $(this).find('a').attr('href');
      if(target=='#create_vms') {
        window.location.href="/castlight/createvm"; 
      } else if(target=='#utilization') {
        window.location.href="/castlight/utilization";
      } else if(target == '#manage_vms') {
        window.location.href="/castlight/managevms";
      }
    }); 
    
});
var timerObj;
/*function  registerVMAction () {
  $('.content-table').find('a').click(function()  {
        return confirm('Are you sure?');
    });
}*/

function  registerVMAction () {
  $('.content-table tbody tr td a').click(function()  {
    var self = this;
    var server_id = $(this).parent('td').parent('tr').attr('server-id');
    var action = $(this).data('action');

    var choice = confirm('Are you sure?');
    var selected_row = $(self).parent('td').parent('tr');
    if (choice) {

      $('#assignFloatingIpModal #floating_ip_form').submit(function(e){
        e.preventDefault();
        floating_ip_id = $('#assignFloatingIpModal form select[name=floating_ip_list] :selected').val()
        
        assignFloatingIP(server_id, floating_ip_id);
      });
      $.ajax({
        type: 'GET',
        url: '/castlight/managevms/?action='+ action +'&server_id='+server_id,
        dataType:'json',
        success: function(data){
          
          if( $(selected_row).has("td.loading_button").length == 0) {
              var slice_length = 0;
              if(action == 'stop' || action == 'reset') {
                slice_length = -4;
              } else if(action == 'start' ) {
                slice_length = -3;
              } else if (action == 'delete') {
                var vmstate = $('td:nth-child(2)', $(selected_row)).text();
                if(vmstate == 'BOOTING UP') {
                  slice_length = -1;
                } else if (vmstate == 'RUNNING') {
                  slice_length = -3;
                } else if (vmstate == 'SHUTDOWN') {
                  slice_length = -2;
                } else {
                  slice_length = -1;
                }
              } else if (action == 'associate') {

                $('#assignFloatingIpModal #floating_ip_menu').empty();
                for( i=0;i<data["floatingIp_list"].length;++i) {
                  $('#assignFloatingIpModal #floating_ip_menu').append('<option value='+data["floatingIp_list"][i]['id']+'>'+data["floatingIp_list"][i]['address']+'</option>');
                }
                $("#assignFloatingIpModal").modal('show');
                return choice;
              } else if (action == 'disassociate') {
                //alert(data["floatingIp_list"]["success"]);
                if (typeof data['floatingIp_list']['success'] !== 'undefined') {
                  //vm_ip = $('td:nth-child(4)', $(selected_row)).text();
                  //fixed_ip = vm_ip.split('/')[0]
                  $('td:nth-child(4)', $(selected_row)).html('');
                  $('td:nth-last-child(1) a').data('action', 'associate');
                  $('td:nth-last-child(1) a', $(selected_row)).html('<img src="/static/castlight/img/associate.png" width="18" title="Associate Floating IP" />');
                } else {
                  alert(data['floatingIp_list']['error']);
                }

                return choice;
              }
              $('td', $(selected_row)).slice(slice_length).detach();
            $(selected_row).append('<td colspan="'+(-(slice_length-1))+'" class="loading_button" ><img src="/static/castlight/img/loading1.gif"></td>');
          }
          timerObj = setInterval(getVMStatus, 2000, server_id, action, selected_row);
          //getVMStatus(server_id, action, selected_row);
        },
        error: function(e) {
          console.log(e);
          alert("error");
        }
      });
      
    }
    else {
      return choice
    }
  });
}

function assignFloatingIP(server_id, floating_ip_id) {
  
  $.ajax({
      type:"POST",
      url:"/castlight/managevms/",
      data: {
        'server_id' : server_id,
        'floating_ip_id': floating_ip_id,
        'csrfmiddlewaretoken':$('#assignFloatingIpModal form input[name=csrfmiddlewaretoken]').val()
      },
      success: function(data) {
        if (typeof data['error'] !== 'undefined') {
          alert(data['error']);
        }
        window.location.href = "/castlight/managevms";
      },
      error: function(e) {
        console.log(e);
        alert("Error assigning floating IP");
      }
    });
}

function getVMStatus(server_id, action, selected_row) {
  //var self = this;
  var result = [];
  if(action == 'delete') {
    $(selected_row).remove();
    return;
  }

  $.ajax({
    type: 'GET',
    url: '/castlight/getvmstatus/?server_id='+server_id,
    success: function(data) {
      ip_address = $('td:nth-child(4)', $(selected_row)).text();
      
      if(action == 'stop') {
        
        if( data.indexOf('SHUTOFF') != -1 ) {
          clearTimeout(timerObj);
          $('td', $(selected_row)).slice(-1).detach();
          result.push('<td colspan="2"><a data-action="start" ><img src="/static/castlight/img/start.png" width="18" title="Start" /></a></td>');
          result.push('<td><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');


          //$(selected_row).append(result.join(''));
          $('td:nth-child(2)', $(selected_row)).html('SHUTDOWN');

          if(ip_address.length == 0) {
            result.push('<td><a data-action="associate"><img src="/static/castlight/img/associate.png" width="18" title="Aassociate Floating IP" /></a></td>');
          } else {
            result.push('<td><a data-action="disassociate"><img src="/static/castlight/img/disassociate.png" width="18" title="Dissociate Floating IP" /></a></td>');
          }
          $(selected_row).append(result.join(''));
          registerVMAction();
          //clearTimeout(timerObj);
        } /*else {
          $('td', $(selected_row)).slice(-1).remove();
          result.push('<td><a data-action="stop"><img src="/static/castlight/img/stop.png" width="18" title="Stop" /></a></td>');
          result.push('<td><a data-action="reset"><img src="/static/castlight/img/restart.png" width="18" title="Reset" /></a></td>');
          result.push('<td><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          $('td:nth-child(2)', $(selected_row)).html("RUNNING");
        }*/
        
        
      }
      else if (action == 'start' || action == 'reset') {
        
        if( data.indexOf('ACTIVE') != -1 ) {
          clearTimeout(timerObj);
          $('td', $(selected_row)).slice(-1).detach();
          result.push('<td><a data-action="stop"><img src="/static/castlight/img/stop.png" width="16" title="Stop" /></a></td>');
          result.push('<td><a data-action="reset"><img src="/static/castlight/img/restart.png" width="18" title="Reset" /></a></td>');
          result.push('<td><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          //$(selected_row).append(result.join(''));
          $('td:nth-child(2)', $(selected_row)).html('RUNNING');
          if(ip_address.length == 0) {
            result.push('<td><a data-action="associate"><img src="/static/castlight/img/associate.png" width="18" title="Aassociate Floating IP" /></a></td>');
          } else {
            result.push('<td><a data-action="disassociate"><img src="/static/castlight/img/disassociate.png" width="18" title="Dissociate Floating IP" /></a></td>');
          } 
          $(selected_row).append(result.join(''));
          registerVMAction();
          //clearTimeout(timerObj);
        } /*else {
          $('td', $(selected_row)).slice(-1).remove();
          result.push('<td><a data-action="start"><img src="/static/castlight/img/start.png" width="18" title="Start" /></a></td>');
          result.push('<td colspan="2"><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          $('td:nth-child(2)', $(selected_row)).html('SHUTDOWN');
          
        }*/
        
        
      }
      else if (action == 'create') {
        if( data.indexOf('ERROR') != -1 ) {
          clearTimeout(timerObj);
          $('td', $(selected_row)).slice(-1).detach();
          $(selected_row).append('<td colspan="3"><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          $('td:nth-child(2)', $(selected_row)).html(data);
          registerVMAction();
        } else if ( data.indexOf('ACTIVE') != -1 ) {
          result = [];
          clearTimeout(timerObj);
          $('td', $(selected_row)).slice(-1).detach();
          result.push('<td><a data-action="stop"><img src="/static/castlight/img/stop.png" width="18" title="Stop" /></a></td>');
          result.push('<td><a data-action="reset"><img src="/static/castlight/img/restart.png" width="18" title="Reset" /></a></td>');
          result.push('<td><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          if(ip_address.length == 0) {
            result.push('<td><a data-action="associate"><img src="/static/castlight/img/associate.png" width="18" title="Aassociate Floating IP" /></a></td>');
          } else {
            result.push('<td><a data-action="disassociate"><img src="/static/castlight/img/disassociate.png" width="18" title="Dissociate Floating IP" /></a></td>');
          }
          $(selected_row).append(result.join(''));
          $('td:nth-child(2)', $(selected_row)).html('RUNNING');
          registerVMAction();
        }
      }
      
    },
    error: function(e) {
      console.log(e);
      clearTimeout(timerObj);
      if( $(selected_row).has("td.loading_button").length > 0) {
        $('td', $(selected_row)).slice(-1).detach();
        if(action == 'stop') {
          result.push('<td><a data-action="start"><img src="/static/castlight/img/start.png" width="18" title="Start" /></a></td>');
          result.push('<td><a data-action="reset"><img src="/static/castlight/img/restart.png" width="18" title="Reset" /></a></td>');
          result.push('<td><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          $('td:nth-child(2)', $(selected_row)).html("RUNNING");
        } else if (action == 'start') {
          result.push('<td><a data-action="start"><img src="/static/castlight/img/start.png" width="18" title="Start" /></a></td>');
          result.push('<td colspan="2"><a data-action="delete"><img src="/static/castlight/img/delete.png" width="18" title="Delete" /></a></td>');
          $('td:nth-child(2)', $(selected_row)).html('SHUTDOWN');
        }
        if(ip_address.length == 0) {
          result.push('<td><a data-action="associate"><img src="/static/castlight/img/associate.png" width="18" title="Aassociate Floating IP" /></a></td>');
        } else {
          result.push('<td><a data-action="disassociate"><img src="/static/castlight/img/disassociate.png" width="18" title="Dissociate Floating IP" /></a></td>');
        }
        $(selected_row).append(result.join(''));
      }
      alert("error");
    }
  });
}

function registerVMCreate() {
  $('.tab-content #create_vms form').on('submit', function(event){
    
    $('#gif').css('visibility', 'visible');
    
    $.ajax({
      type:"POST",
      url:"/castlight/createvm/",
      data: {
        'vmname': $('.tab-content #create_vms input[name=vmname] ').val(),
        'vmrole': $('.tab-content #create_vms select[name=vmrole] :selected').val(),
        'vmimage': $('.tab-content #create_vms select[name=vmimage] :selected').val(),
        'network_id': $('.tab-content #create_vms select[name=network_list] :selected ').val(),
        'csrfmiddlewaretoken':$('.tab-content #create_vms input[name=csrfmiddlewaretoken]').val()
      },
      success: function(data) {
        
        $('#gif').css('visibility', 'hidden');
        //alert('vm created successfully');
        window.location.href = "/castlight/managevms";
      },
      error: function(e) {
        $('#gif').css('visibility', 'hidden');
        console.log(e);
        alert("Error creating VM");
      }
    });
    return false;
  });
}

function registerVMBooting() {

  var selected_row = $('.content-table tbody tr:nth-child(1)');
  var vmstate = $('.content-table tbody tr:nth-child(1) td:nth-child(2)').text();
  
  var server_id = $('.content-table tbody tr:nth-child(1)').attr('server-id');
  if( vmstate == 'BOOTING UP') {

    //$('td', $(selected_row)).slice(-1).detach();
    $(selected_row).append('<td colspan="2" class="loading_button" ><img src="/static/castlight/img/loading1.gif"></td>');
    timerObj = setInterval(getVMStatus, 2000, server_id, 'create', selected_row);
  }

}


