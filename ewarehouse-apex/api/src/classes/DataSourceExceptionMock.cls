@isTest
public with sharing class DataSourceExceptionMock {
	
	public class AllExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
		public List<Farmer__c> getFarmer(String name){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateFarmer(Farmer__c farmer){
			throwError();
			return null;
		}
	}
	
	public class UpdateFarmerExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
		EwarehouseDataSource ds = new EwarehouseDataSource();
		public List<Farmer__c> getFarmer(String name){
			return ds.getFarmer(name);
		}
		
		public Database.SaveResult updateFarmer(Farmer__c farmer){
			return database.insert(new Farmer__c());
		}
	}
	
	public static void throwError(){
		insert new Farmer__c();
	}
	
	
}