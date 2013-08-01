public with sharing class CommodityEditController {
	
	private ApexPages.StandardController stdController;
		
    public Id commodityId {get ; set;}
    
    public CommodityEditController(ApexPages.StandardController controller){
    	stdController = controller;
    	commodityId = 'a0Yi0000000gQ5V';
    }
    public CommodityEditController(){
    	commodityId = 'a0Yi0000000gQ5V';
    }
    
    public PageReference save() { 
        // Put my own stuff here
        System.debug(LoggingLevel.Debug, 'Hooray');

        // Do the standard save action  
        return this.stdController.save(); 
    }
    
    public String isValid(){
    	System.debug(LoggingLevel.Debug, 'treu');
    	return 'treu';
    }

//standardController="Commodities__c"
}