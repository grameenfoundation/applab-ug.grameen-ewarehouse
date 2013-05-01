public with sharing class EwarehouseDataSource implements IEwarehouseDataSource {
	/*
	 * This method returns a Farmer object from SalesForce wuth the appropriate information needed for the Client object
	*/
	public List<Farmer__c> getFarmer(String name){
		
		// Select the client by name (Farmer ID in SalesForce)
		return [SELECT 
					ID, 
					Name, 
					Person__r.First_Name__c,
					Person__r.Last_Name__c,
					Person__r.Date_of_Birth__c,
					Person__r.Mobile_Number__c,
					Person__r.Phone_Number__c,
					Person__r.ID_Number__c,
					Person__r.Village__c,
					Person__r.District__r.Name,
					Person__r.City__c,
					Person__r.Country__r.Name,
					Person__r.Gender__c
				FROM Farmer__c WHERE Name = :name];
		
	}
	
	public Database.SaveResult updateFarmer(Farmer__c farmer){
		return Database.update(farmer);
	}
	
	
	public interface IEwarehouseDataSource{
		List<Farmer__c> getFarmer(String name);
		Database.SaveResult updateFarmer(Farmer__c farmer);
	}
	
	
}