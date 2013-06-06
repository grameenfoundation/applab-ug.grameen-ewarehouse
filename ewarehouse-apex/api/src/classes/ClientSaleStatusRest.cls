@RestResource(urlMapping='/ewarehouse/clientsalestatus/*')
global class ClientSaleStatusRest extends EwarehouseServiceBase {
    @HttpPost
    global static EwarehouseServiceBase.ServiceResultResponse updateClientSaleStatus(){ //String id, String saleStatus
        
        // take the information from the parameters
        String jsonString = RestContext.request.requestBody.toString(); 
        system.debug('json: ' + jsonString);
        
        // parse the update data
        Map<String, String> parameters = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);
        system.debug(parameters);
        
        // get id parameter
        String id = EwarehouseServiceBase.getParameter(parameters, 'Id');
        if(id == null){
            System.debug(LoggingLevel.Debug, 'ERROR: request param [Id] should not be null');
            return new ErrorResponse('We could find required parameter [Id]');
        }
        
        String status = EwarehouseServiceBase.getParameter(parameters, 'SaleStatus');
        if(status == null){
            System.debug(LoggingLevel.Debug, 'ERROR: request param [SaleStatus] should not be null');
            return new ErrorResponse('We could find required parameter [SaleStatus]');
        }
        
        // get the appropriate client
        List<Farmer__c> lstClient = null;
        
        try {
            lstClient = EwarehouseServiceBase.dataSource.getFarmer(id);
        }
        catch(Exception e){
            system.debug(LoggingLevel.Error, 'EXCEPTION: ' + e);
            return new ExceptionResponse(e);
        }
        
        // check if the client exists
        if (lstClient.size() == 0) {
            // no client found to update
            return new ErrorResponse('We could find a client with the gived id: ['+ id +']');
        }
        
        // seems there is a farmer with this Id to update
        Farmer__c clObj = lstClient.get(0);
        clObj.Sale_Status__c = status;
        
        // save the update
        Database.SaveResult results;
        try {
            results = EwarehouseServiceBase.dataSource.updateFarmer(clObj);
        }
        catch(Exception e){
            system.debug(LoggingLevel.Error, 'ERROR: ' + e);
            return new ExceptionResponse(e);
        }
        
        system.debug(LoggingLevel.Debug, results);
        
        // check if the update was succesful otherwise return the errors -- TODO check how I can get a DML Error in the update for testing
        if(results.isSuccess()){
            return new SuccessResponse('Updated: client id ['+id+'], sale-status: ['+status+']');
        }
        else{
            system.debug(LoggingLevel.Error, 'ERROR: ' + results.getErrors());
            return new DmlErrorResponse('We could update client with the gived id: ['+ id +']', results.getErrors());
        }
    }
}