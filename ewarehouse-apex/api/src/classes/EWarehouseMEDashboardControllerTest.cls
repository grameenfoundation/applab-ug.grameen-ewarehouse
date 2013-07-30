@isTest
public with sharing class EWarehouseMEDashboardControllerTest {
	
	static void loadTestData(){
		 // insert test data
        DataSourceMock.insertTestData();
        
        Country__c country = DataSourceMock.getTestCountry();
        insert country;
        
        District__c district = DataSourceMock.getTestDistrict();
        insert district;
        
		Person__c vkw = DataSourceMock.getTestPerson(country, district);
        vkw.Type__c = 'VKW';
        insert vkw;
        
	}
     
    static testMethod void testConstructor(){
        loadTestData();
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        
        
    }
    
    static testMethod void getImpactData(){
        
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> impactData = controller.getImpactData();
        
        System.assertEquals(impactData.size(), 8);
        System.assertEquals('No of Farmers registered', impactData[0].Name);
        System.assertEquals('2', impactData[0].Count);
        System.assertEquals('Female', impactData[1].Name);
        System.assertEquals('1', impactData[1].Count);
        System.assertEquals('Male', impactData[2].Name);
        System.assertEquals('1', impactData[2].Count);
        System.assertEquals('No of Village Knowledge Workers registered', impactData[3].Name);
        System.assertEquals('1', impactData[3].Count);
        System.assertEquals('Total loans', impactData[4].Name);
        System.assertEquals('2', impactData[4].Count);
        System.assertEquals('Repaid loans', impactData[5].Name);
        System.assertEquals('1', impactData[5].Count);
        System.assertEquals('Repaid ratio (loans)', impactData[6].Name);
        System.assertEquals('0.50', impactData[6].Count);
        System.assertEquals('No of farmers fully paid for sales', impactData[7].Name);
        System.assertEquals('2', impactData[7].Count);
        
    }
    
    static testMethod void getFarmersByGender(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getFarmersByGender();
        
        System.assertEquals(testData.size(), 2);
        System.assertEquals('Female', testData[0].Name);
        System.assertEquals('1', testData[0].Count);
        System.assertEquals('Male', testData[1].Name);
        System.assertEquals('1', testData[1].Count);
    }
    
    static testMethod void getFarmersByAcre(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getFarmersByAcre();
        
        System.assertEquals(testData.size(), 5);
        System.assertEquals('0 - 10', testData[0].Name);
        System.assertEquals('1', testData[0].Count);
        System.assertEquals('11 - 20', testData[1].Name);
        System.assertEquals('0', testData[1].Count);
        System.assertEquals('21 - 30', testData[2].Name);
        System.assertEquals('0', testData[2].Count);
        System.assertEquals('31 - 40', testData[3].Name);
        System.assertEquals('1', testData[3].Count);
        System.assertEquals('> 40', testData[4].Name);
        System.assertEquals('0', testData[4].Count);
       
    }
    
    static testMethod void getFarmersByCrop(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getFarmersByCrop();
        
        System.assertEquals(1, testData.size());
        System.assertEquals('Maize', testData[0].Name);
        System.assertEquals('2', testData[0].Count);
    }
    
    static testMethod void getFarmersByLivestock(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getFarmersByLivestock();
        
        System.assertEquals(1, testData.size());
        System.assertEquals('Goats', testData[0].Name);
        System.assertEquals('2', testData[0].Count);
    }
    
    static testMethod void getGrainCollected(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getGrainCollected();
        System.debug('getGrainCollected' + testData);
        System.assertEquals(1, testData.size());
        System.assertEquals('Beans', testData[0].Name);
        System.assertEquals('180', testData[0].Count);
    }
    
    static testMethod void getGrainSold(){
        loadTestData();
        
        EWarehouseMEDashboardController controller = new EWarehouseMEDashboardController();
        List<EWarehouseMEDashboardController.NameCount> testData = controller.getGrainSold();
        System.debug('getGrainSold' + testData);
        System.assertEquals(0, testData.size());
        //System.assertEquals('Goats', testData[0].Name);
        //System.assertEquals('2', testData[0].Count);
    }
    
    
    
   // public class NameCount 
    
    //public class IntegerRange 
}