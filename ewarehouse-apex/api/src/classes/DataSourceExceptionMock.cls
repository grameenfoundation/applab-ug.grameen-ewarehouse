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
		
		public List<Farmer__c> getFarmersByStatus(String status){
			throwError();
			return null;
		}
		
		public Farmer__c[] getFarmers(Set<String> farmerIds){
			throwError();
			return null;
		}
		
		public List<Loan__c> getLoan(String id){
			throwError();
			return null;
		}
	}
	
	public class UpdateFarmerExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
		EwarehouseDataSource ds = new EwarehouseDataSource();
		public List<Farmer__c> getFarmer(String name){
			return ds.getFarmer(name);
		}
		
		public List<Farmer__c> getFarmersByStatus(String status){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateFarmer(Farmer__c farmer){
			throwError();
			return null;
		}
		
		public Farmer__c[] getFarmers(Set<String> farmerIds){
			throwError();
			return null;
		}
		
		public List<Loan__c> getLoan(String id){
			throwError();
			return null;
		}
	}
	
	public static void throwError(){
		insert new Farmer__c();
	}
	
	
}