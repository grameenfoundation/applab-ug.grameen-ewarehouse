public with sharing class HarvestAndLoanSurveyController extends DynamicDashboardBaseController{
    public HarvestAndLoanSurveyController() {
        setDashboardName('Harvest & Loan Dashboard');
        setSections(loadSections());
    }
    
    public List<Harvest__c> getLeadData(){
    	List<Harvest__c> harvestList = [SELECT 
											Id,
											Name,
											Crop__c,
											Farmer__r.Name,
											Farmer__r.Person__r.First_Name__c,
											Farmer__r.Person__r.Middle_Name__c,
											Farmer__r.Person__r.Last_Name__c,
											Farmer__r.Person__r.ID_Number__C,
											Quantity_Harvested__c,
											Quantity_Accepted__c,
											Quantity_Rejected__c
											FROM Harvest__c
											WHERE Farmer__c NOT IN (SELECT Farmer__c FROM Loan__c WHERE Loan_Contract_No__c != '')
											ORDER BY Farmer__c ASC NULLS FIRST];
	   return harvestList;
    }
    
    public PageReference exportPage(){
    	PageReference newPage = new PageReference('/apex/HarvestAndLoanSurveyExport');
    	
    	return newPage;
    }
    
    public String getFileName(){
        return 'harvestloan-export-' + DateTime.now().format('yyyyMMddHHmmss');
    }
    public String getRunDate(){
        return DateTime.now().format('dd MMM yyyy, HH:mm:ss');
    }
}