@RestResource(urlMapping='/ewarehouse/sales/*')
global class SalesRestService extends EwarehouseServiceBase  {
	
	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getSales() {
    	
    	// set the New status
    	String status = 'New';
    	
    	// create a list of Sale objects for JSOn
    	List<Sale> sales = new List<Sale>();
    	
    	// retrieve all new Sales
    	Sale__c[] newSales;
    	// we put the whole block inside a try because there are a lot of places where an exception might occur
    	// TODO check what is really needed
    	try {
    	
        	newSales = EwarehouseServiceBase.dataSource.getSales(status);
        	
        	// iterate through the new sale__c objects and convert to Sale
	    	for(Sale__c sObj : newSales){
	    		Sale_Farmer_Association__c[] sfList = EwarehouseServiceBase.dataSource.getSaleFarmers(sObj.Id);
	    		// create Sale object
	    		Sale sale = new Sale();
	    		sale.Id = sObj.Id;
	    		sale.Amount = sObj.Sale_Price__c;
	    		
	    		// create an array of SaleFarmer objects
	    		List<SaleFarmer> saleFarmerList = new List<SaleFarmer>();
		    	for(Sale_Farmer_Association__c obj : sfList){
		    		SaleFarmer sf = new SaleFarmer();
		    		sf.AmountApplied = obj.Amount_Applied__c;
		    		sf.FarmerId = obj.Farmer__c;
		    		sf.FeeDue = obj.Fee_Due__C;
		    		sf.FeePaid = obj.Fee_Paid__C;
		    		saleFarmerList.add(sf);
		    	}
		    	sale.SaleFarmers = saleFarmerList;
	    		
	    		// add the sale to the list of sales
	    		sales.add(sale);
	    	}
        }
        catch(Exception e){
        	system.debug(LoggingLevel.Error, 'ERROR: ' + e);
	       	return new ExceptionResponse(e);
        }
     	
 		// return the objects
    	return new SalesResponse(sales);
    }
    
    @HttpPost
    global static EwarehouseServiceBase.ServiceResultResponse updateSales() {
    	// take the JSON from the body
    	String jsonString = RestContext.request.requestBody.toString(); 
        system.debug(LoggingLevel.Info, 'json: ' + jsonString);
        
        // parse the sales update data
        List<Map<String, String>> parameters = (List<Map<String, String>>) JSON.deserialize(jsonString, List<Map<String, String>>.class);
        system.debug(LoggingLevel.Debug, parameters);
        
        // Store all the Ids in a Set and the objects in its own update map to be able to find the Status by Id
        Set<String> ids = new Set<String>();
        Map<String, String> updateMap = new Map<String, String>();
        for(Map<String, String> item : parameters){
            // first check if the required parameters are available
            if(!item.containsKey('Id'))
                return new ErrorResponse('JSON ERROR: We could find required parameter [Id] in one of the objects');
            if(!item.containsKey('Status'))
                return new ErrorResponse('JSON ERROR: We could find required parameter [Status] in one of the objects');
                
            // build id not found exception
            ids.add(item.get('Id'));
            updateMap.put(item.get('Id'), item.get('Status'));
        }
        system.debug(LoggingLevel.Debug, ids);
        
        // put the whole loop for updating records in a try-catch, any exception thrown will be returned to the user
        try {
            // build a query with all the Ids and update item per item
            for(Sale__c s: EwarehouseServiceBase.dataSource.getSales(ids)){
                // check if the Id can be found in the update map, using the Sale.Name field
                if(!updateMap.containsKey(s.Id))
                    return new ErrorResponse('Trying to update ['+s.Id+'], while the Status is not stored in the Map.');
                    
                // update the sale, set the status to the one given
                s.Status__c = updateMap.get(s.Id);
                EwarehouseServiceBase.dataSource.updateSale(s);
                
                // remove the sale from the update map, the map while then be left with sales not found in the query 
                updateMap.remove(s.Id);
            }   
        }
        catch(Exception e){
            system.debug(LoggingLevel.Error, 'EXCEPTION: ' + e);
            return new ExceptionResponse(e);
        }
        
        if(updateMap.isEmpty()){
            return new SuccessResponse('Update success');
        }
        else {
            system.debug(LoggingLevel.Info, updateMap);
            return new ErrorMapResponse('Not all IDs where found as sales, attached Ids not updated.', updateMap);
        }
    }
    
    global class SalesResponse extends ServiceResultResponse {
		public SalesResponse(Sale[] sales){
			this.code = '200';
			this.description = 'OK';
			this.sales = sales;
		}
		
		public Sale[] sales;
	}
	
	public class Sale {
		public String Id { get; set; }
		public Decimal Amount { get; set; }
		public SaleFarmer[] SaleFarmers { get; set; }
	}
	
	public class SaleFarmer {
		public String FarmerId { get; set; }
		public Decimal AmountApplied { get; set; }
		public Decimal FeeDue { get; set; }
		public Decimal FeePaid { get; set; }
	}
	
}