$(function() {

  var latest_transactions = [];
  getNewData();
  showLatestTransactions();

  function getNewData() {
    $.ajax({
      url : "json/transactions",
      type : "GET",
      dataType : "json",
      success : function(json) {
        latest_transactions = json;
      },
      error : function(xhr, status, errorThrown) {
        console.log("Error: " + errorThrown);
        console.log("Status: " + status);
        console.dir(xhr);
      },
      complete : function(xhr, status) {
        setTimeout(getNewData, 2000);    
      }
    });    
  }
  
  function showLatestTransactions() {
    /* Start at the end of the latest_transactions array, 
     * if you find a transaction that is not yet in the <table>, add it to the table
     * then remove it from the latest_transactions */
    try {
      while (1) {
        var oldest = latest_transactions.pop();
        if (oldest) {
          var selector = "tr[data-tid='" + oldest.id + "']"; 
          if ($(selector).length) {
            continue;
          }        
          $("#txs tr:first").after(createTxnHTML(oldest));
          $(selector).find('div').hide().slideDown('slow');
          while ($("#txs tr").length > 10) {
            $("#txs tr:last").remove();
          }
        }
        break;
      }
    }
    finally {
      setTimeout(showLatestTransactions, Math.floor((Math.random() * 2000) + 300));    
    }
  }  
  
  function createTxnHTML(json) {
    return '<tr data-tid="' + json.id + '"><td><div style="display: block;"><a href="/transactions/' + json.id + '">' + json.id + '</a></div></td>' +
           '<td class="hidden-phone" data-time="'+json.time+'"><div style="display: block;">'+json.time+'</div></td>' +
           '<td><div style="display: block;"><button class="btn btn-success cb"><span data-c="">'+json.amount+'</span></button>' +
           '</div></td></tr>';
  }
}); 