function(task, response){
  var rows = [];
  for(let i = 0; i < response.length; i++){
    try{
        var data = JSON.parse(response[i]['response']);
    }catch(error){
        return escapeHTML(response);
    }
    data.forEach(function(r){
      let row_style = "";
      rows.push({"pid": escapeHTML(r['process_id']),
                          "ppid": escapeHTML(r['parent_process_id']),
                          "path": escapeHTML(r['bin_path']),
                          "user": escapeHTML(r['user']),
	      		  "name": escapeHTML(r['name']),
	      		  "arch": escapeHTML(r['architecture']),
                          "row-style": row_style,
                           "cell-style": {}
                         });
    });
  }
  return support_scripts['hermes_create_table']([{"name":"pid", "size":"10em"},{"name":"ppid", "size":"10em"},{"name":"arch", "size":"10em"},{"name": "user", "size": "10em"},{"name": "name", "size": "10em"},{"name":"path", "size":""}], rows);
}
