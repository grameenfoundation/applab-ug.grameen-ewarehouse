public with sharing class EWarehouseMEDashboardController  {
	
	private List<String> cropValues;
	private List<String> livestockValues;
	private List<String> storageMaterialValues;
	private List<String> storageLocationValues; 
	
	private Info ewInfo;
	private Boolean editMode = false;
	
    private String farmersTrained = 'No of Farmers registered';
    private String farmersHadTraining = 'No of Farmers trained on post-harvest handling';
    private String farmersNewStorageTechniques = 'No of Farmers implementing new storage techniques';
    private String increaseInFarmersStr = 'Increase in farmers storing grains and delaying sale';
    private String increaseInFinancialAccessStr = 'Increase in farmers with access to financial services';
    private String repaymentRatioLbl = 'Repaid ratio (loans)';
    private String totalLoansLbl = 'Total loans';
    private String repaidLoansLbl = 'Repaid loans';
            
    private String cvCoveredLabel = 'Commercial Villages covered:';
    private String farmersReceivingInformationLabel = 'Number of farmers receiving market information through SMS :';
    private String farmersGrainChecksLabel = 'Number of checks conducted by FCI staff and VKWs on grain stored:';
    private String inputsPurchasedLabel = 'Volume of inputs/fertilizers purchased by FCI:';
    private String trainingsDoneOnInputAdoptionLabel = 'Number of trainings on adoption of inputs:';
    private String totalInputPriceLabel = 'Number of farmers compared against total input purchased:';
    
    private Integer acreSteps = 5;

    private Integer totalFarmers = 0;
	private List<NameCount> impactData;
	private List<NameCount> farmersByGender;
	private List<NameCount> farmersByAcre;
	private List<NameCount> farmersByPPI;
	private List<NameCount> farmersByCrop;
	private List<NameCount> farmersByLivestock;
    private List<NameCount> farmersByStorageMaterial;
    private List<NameCount> farmersByStorageLocation;
    private List<NameCount> grainCollected;
	private List<NameCount> grainSold;
	private List<NameCount> fciInformation;
	
	private List<IntegerRange> acreRanges;
	private List<IntegerRange> ppiRanges;
	private List<String> newStorageLocations;
	private List<String> newStorageMaterial;
	
    public EWarehouseMEDashboardController() {
    	loadData();
    }
    
    private void loadData(){
    	
    	ewInfo = new Info();
    	
    	// set defaults, ranges and values
    	acreRanges = new List<IntegerRange>();
    	acreRanges.add(new IntegerRange(0, 10));
    	acreRanges.add(new IntegerRange(11, 20));
    	acreRanges.add(new IntegerRange(21, 30));
    	acreRanges.add(new IntegerRange(31, 40));
    	acreRanges.add(new IntegerRange(41, -1));
    	
    	ppiRanges = new List<IntegerRange>();
        ppiRanges.add(new IntegerRange(0, 24));
        ppiRanges.add(new IntegerRange(25, 49));
    	ppiRanges.add(new IntegerRange(50, 74));
    	ppiRanges.add(new IntegerRange(75, 100));
    	
    	newStorageLocations = new List<String>();
    	newStorageLocations.add('House off ground');
    	newStorageLocations.add('Granary off ground');
    	newStorageMaterial = new List<String>();
    	newStorageMaterial.add('Plastic bags');
        newStorageMaterial.add('Dedicated room');
        
    	loadCropValues();
    	loadLivestockValues();
    	loadStorageMaterialValues();
    	loadStorageLocationValues();
    	
    	// reset all the data
    	impactData = new List<NameCount>();
        farmersByGender = new List<NameCount>();
        farmersByAcre = new List<NameCount>();
        farmersByPPI = new List<NameCount>();
    	farmersByCrop = new List<NameCount>();
    	farmersByLivestock = new List<NameCount>();
        farmersByStorageMaterial = new List<NameCount>();
        farmersByStorageLocation = new List<NameCount>();
        grainCollected = new List<NameCount>();
    	grainSold = new List<NameCount>();
    	fciInformation = new List<NameCount>();
    	
    	// load farmers by gender and also set the total farmers
    	loadFarmersByGender();
    	loadFarmersByTraining();
    	loadVKWInformation();
    	loadFarmersByAcre();
    	loadFarmersByPPI();
    	loadFarmersByCrop();
    	loadFarmersByLivestock();
    	loadFarmersByStorageMaterial();
    	loadFarmersByStorageLocation();
    	loadFarmersIncrease();
    	loadLoanInformation();
    	loadFarmersWhoArePaid();
    	loadGrainCollected();
    	loadGrainSold();
    	loadFciInformation();
    	
    }
    
    public List<NameCount> getImpactData(){
        return impactData;
    }
    
    public List<NameCount> getFarmersByGender(){
        return farmersByGender;
    }
    
    public List<NameCount> getFarmersByAcre(){
        return farmersByAcre;
    }
    
    public List<NameCount> getFarmersByCrop(){
        return farmersByCrop;
    }
    
    public List<NameCount> getFarmersByLivestock(){
        return farmersByLivestock;
    }
    
    public List<NameCount> getGrainCollected(){
        return grainCollected;
    }
    
    public List<NameCount> getGrainSold(){
        return grainSold;
    }
    
    public List<NameCount> getFarmersByStorageMaterial(){
        return farmersByStorageMaterial;
    }
    
    public List<NameCount> getFarmersByStorageLocation(){
        return farmersByStorageLocation;
    }
    
    public List<NameCount> getFciInformation(){
        return fciInformation;
    }
    
    private void loadFarmersByGender(){
    	
        
        for(AggregateResult ar: [SELECT Person__r.Gender__c, COUNT(Id) c FROM Farmer__c GROUP BY Person__r.Gender__c ORDER BY Person__r.Gender__c DESC]){
            farmersByGender.add(new NameCount(String.valueOf(ar.get('Gender__c')), String.valueOf(ar.get('c'))));
            totalFarmers += Integer.valueOf(ar.get('c'));
        }
        
        // add the total amount of farmers to the impactData
        impactData.add(new NameCount(farmersTrained, String.valueOf(totalFarmers)));
        for(NameCount nc : farmersByGender){
        	impactData.add(nc);
        }
    }
    
    private void loadFarmersByTraining(){
    	Integer hadTraining = Database.countQuery('SELECT Count() FROM Farmer__c WHERE Had_Post_Harvest_Handling_Training__c = true');
    	String newStorageLocationStr = '';
        String newStorageMaterialStr = '';
        
    	for(String s : newStorageLocations){
            newStorageLocationStr += '\''+ s + '\',';
        }
        newStorageLocationStr = newStorageLocationStr.removeEnd(',');
        
        for(String s : newStorageMaterial){
            newStorageMaterialStr += '\''+ s + '\',';
        }
        newStorageMaterialStr = newStorageMaterialStr.removeEnd(',');
        
    	System.debug('SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Material__c INCLUDES ('+newStorageMaterialStr+') OR Crop_Storage_Location__c INCLUDES ('+newStorageLocationStr+')');
    	Integer useNewStorageTechniques = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Material__c INCLUDES ('+newStorageMaterialStr+') OR Crop_Storage_Location__c INCLUDES ('+newStorageLocationStr+')');
    	impactData.add(new NameCount(farmersHadTraining, String.valueOf(hadTraining)));
    	impactData.add(new NameCount(farmersNewStorageTechniques, String.valueOf(useNewStorageTechniques)));
    	
    }
    
    private void loadVKWInformation(){
        Integer vkws = Database.countQuery('SELECT COUNT() FROM Person__c WHERE Type__c = \'VKW\'');
        impactData.add(new NameCount('No of Village Knowledge Workers registered', String.valueOf(vkws)));
    }
    
    private void loadFarmersWhoArePaid(){
        Integer result = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Sale_Status__c = \'Paid\'');
        impactData.add(new NameCount('No of farmers fully paid for sales', String.valueOf(result)));
    }
    
    private void loadFarmersByAcre(){
    	// make sure they are sorted to loop through them correctly
    	acreRanges.sort();
    	
    	for (IntegerRange range : acreRanges){
    		Integer stepMin = range.min;
    		Integer stepMax = range.max;
    		String q;
    		if(stepMax != -1)
                q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin+' AND Land_Size__c <= '+stepMax;
            else
                q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin;
                
            Integer result = Database.countQuery(q);
            if(stepMax != -1)
                farmersByAcre.add(new NameCount(stepMin+' - '+stepMax, String.valueOf(result)));
            else
                farmersByAcre.add(new NameCount('> ' + (stepMin - 1), String.valueOf(result)));
        }
        
        system.debug(LoggingLevel.Debug, farmersByAcre);
    }
    
    private void loadFarmersByPPI(){
    	// make sure they are sorted to loop through them correctly
       /* ppiRanges.sort();
        
        for (IntegerRange range : ppiRanges){
            Integer ppiMin = range.min;
            Integer ppiMax = range.max;
            String q;
            if(stepMax != -1)
                q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin+' AND Land_Size__c <= '+stepMax;
            else
                q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin;
                
            Integer result = Database.countQuery(q);
            if(stepMax != -1)
                farmersByAcre.add(new NameCount(stepMin+' - '+stepMax, String.valueOf(result)));
            else
                farmersByAcre.add(new NameCount('> ' + (stepMin - 1), String.valueOf(result)));
        }
        
    	farmersByPPI*/
    }
    
    private void loadFarmersByCrop(){
    	for(String crop : cropValues){
    		String q = 'SELECT COUNT() FROM Farmer__c WHERE Crops__c includes (\''+crop+'\')';
    		Integer result = Database.countQuery(q);
    		if(result > 0){
                farmersByCrop.add(new NameCount(crop, String.valueOf(result)));	
    		}
    	}
    }
    
    private void loadFarmersByLivestock(){
        for(String livestock : livestockValues){
            String q = 'SELECT COUNT() FROM Farmer__c WHERE Livestock__c includes (\''+livestock+'\')';
            Integer result = Database.countQuery(q);
            if(result > 0){
                farmersByLivestock.add(new NameCount(livestock, String.valueOf(result))); 
            }
        }
    }
    
    private void loadFarmersByStorageMaterial(){
    	for(String storageMaterial : storageMaterialValues){
            String q = 'SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Material__c INCLUDES (\''+storageMaterial+'\')';
            Integer result = Database.countQuery(q);
            if(result > 0){
                farmersByStorageMaterial.add(new NameCount(storageMaterial, String.valueOf(result))); 
            }
        }
    }
    
    private void loadFarmersByStorageLocation(){
        for(String storageLocation : storageLocationValues){
            String q = 'SELECT COUNT() FROM Farmer__c WHERE Crop_Storage_Location__c INCLUDES (\''+storageLocation+'\')';
            Integer result = Database.countQuery(q);
            if(result > 0){
                farmersByStorageLocation.add(new NameCount(storageLocation, String.valueOf(result))); 
            }
        }
    }
    
    private void loadFarmersIncrease(){
    	
    	// get the increase in farmers from the baseline date
    	String q = 'SELECT COUNT() FROM Farmer__c WHERE CreatedDate < ' + ewInfo.baseLineDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    	Integer baseLineFarmerCount = Database.countQuery(q);
        q = 'SELECT COUNT() FROM Farmer__c';
        Integer currentFarmerCount = Database.countQuery(q);
        
        if(baseLineFarmerCount > 0){
            Decimal increaseInFarmers = (((Decimal)currentFarmerCount - (Decimal)baseLineFarmerCount) / (Decimal)baseLineFarmerCount) * 100;
            impactData.add(new NameCount(increaseInFarmersStr, increaseInFarmers.setScale(2).toPlainString()));
        }
        
        // get the increase in farmers with access to financial services
        //SELECT COUNT() FROM Farmer__c WHERE Access_Financial_Services__c = true AND Id IN (SELECT Farmer__c FROM Loan__c)
        q = 'SELECT COUNT() FROM Farmer__c WHERE Access_Financial_Services__c = true AND CreatedDate < ' + ewInfo.baseLineDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        Integer financialServicesBaseline = Database.countQuery(q);
        List<Farmer__c> financialServices = [SELECT Id FROM Farmer__c WHERE Had_Credit_Access__c = true];
        List<Farmer__c> hadLoan = [SELECT Id FROM Farmer__c WHERE Id IN (SELECT Farmer__c FROM Loan__c)];
        Set<Farmer__c> hasFinancialServicesSet = new Set<Farmer__c>();
        hasFinancialServicesSet.addAll(financialServices);
        hasFinancialServicesSet.addAll(hasFinancialServicesSet);
        
        Integer hasAccessFinancialServices = hasFinancialServicesSet.size();
        
        if(financialServicesBaseline > 0){
            Decimal increaseInAccess = (((Decimal)hasAccessFinancialServices - (Decimal)financialServicesBaseline) / (Decimal)financialServicesBaseline) * 100;
            impactData.add(new NameCount(increaseInFinancialAccessStr, increaseInAccess.setScale(2).toPlainString())); 
        }
    	
    }
    
    private void loadLoanInformation(){
    	
    	Integer repaidLoans = 0;
        Integer totalLoans = 0;
        for(AggregateResult ar: [SELECT COUNT(ID) c, Status__c FROM Loan__c GROUP BY Status__c]){
        	Integer cnt = Integer.valueOf(ar.get('c'));
        	String status = String.valueOf(ar.get('Status__c'));
        	
        	if(status == 'Repaid'){
        		repaidLoans = cnt;
        		totalLoans += cnt;
        	}
        	
        	if(status == 'Approved' || status == 'Service' || status == 'Repaid' || status == 'Overdue'){
        		totalLoans += cnt;
        	}
        }
        
        impactData.add(new NameCount(totalLoansLbl, String.valueOf(totalLoans)));
        impactData.add(new NameCount(repaidLoansLbl, String.valueOf(repaidLoans)));
        
        Decimal ratio = totalLoans != 0 ? (repaidLoans / (Decimal)totalLoans) : 0;
        impactData.add(new NameCount(repaymentRatioLbl, String.valueOf(ratio.setScale(2))));
    }
    
    private void loadGrainCollected(){
    	for(AggregateResult ar: [SELECT SUM(Quantity_Accepted__c) s, Crop__c FROM Harvest__c GROUP BY Crop__c]){
    		Integer quantity = Integer.valueOf(ar.get('s'));
    		String crop = String.valueOf(ar.get('Crop__c'));
    		Integer tons = (quantity * 90) / 1000;
            grainCollected.add(new NameCount(crop, String.valueOf(tons)));
        }
    }
    
    private void loadGrainSold(){
    	// TODO FIX
    	Integer x = 9/0;
        for(AggregateResult ar: [SELECT SUM(Volume_Sold__c) vs FROM Sale__c]){
        	if(ar.get('vs') != null && ar.get('Crop__c') != null){
        		// convert the values
        		Integer quantity = Integer.valueOf(ar.get('vs'));
                String crop = String.valueOf(ar.get('Crop__c'));
                Integer tons = (quantity * 90) / 1000;
                
                // find the appropriate crop
        		Boolean found = false;
        		for(NameCount nc : grainCollected){
        			if(nc.name == crop){
        				nc.count2 = String.valueOf(tons);
        				found = true;
        			}
        		}
        		
        		if(!found){
        			grainCollected.add(new NameCount(crop, '0', String.valueOf(tons)));
        		}
        	}
        }
    }
    
    private void loadFciInformation(){
    	ewInfo = new Info();

    	fciInformation.add(new NameCount(cvCoveredLabel, ewInfo.cvsCovered));
    	fciInformation.add(new NameCount(farmersReceivingInformationLabel, ewInfo.farmersReceivingInformation));
    	fciInformation.add(new NameCount(farmersGrainChecksLabel, ewInfo.farmersGrainChecks));
    	fciInformation.add(new NameCount(inputsPurchasedLabel, ewInfo.inputsPurchased));
    	fciInformation.add(new NameCount(trainingsDoneOnInputAdoptionLabel, ewInfo.trainingsDoneOnInputAdoption));
    	fciInformation.add(new NameCount(totalInputPriceLabel, ewInfo.totalInputPrice / totalFarmers));

    }
    
    private void loadCropValues() {
        if(cropValues == null){
            cropValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crops__c.getDescribe().getPicklistValues()){
                cropValues.add(entry.getValue());
            }
        }
    }
    
    private void loadLivestockValues() {
        if(livestockValues == null){
            livestockValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Livestock__c.getDescribe().getPicklistValues()){
                livestockValues.add(entry.getValue());
            }
        }
    }
    
    private void loadStorageLocationValues() {
        if(storageLocationValues == null){
            storageLocationValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crop_Storage_Location__c.getDescribe().getPicklistValues()){
                storageLocationValues.add(entry.getValue());
            }
        }
    }
    
    private void loadStorageMaterialValues() {
        if(storageMaterialValues == null){
            storageMaterialValues = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crop_Storage_Material__c.getDescribe().getPicklistValues()){
                storageMaterialValues.add(entry.getValue());
            }
        }
    }

   
    
    public class NameCount {
        public String name { get; set; }
        public String count { get; set; }
        public String count2 { get; set; }

        public NameCount(String name, String count, String count2) {
            this.name = name;
            this.count = count;
            this.count2 = count2;
        }
        
        public NameCount(String name, String count) {
            this.name = name;
            this.count = count;
            this.count2 = '0';
        }
        
        public NameCount(String name, Integer count) {
            this.name = name;
            this.count = String.valueOf(count);
            this.count2 = '0';
        }
    }
    
    
    public class IntegerRange implements Comparable {
        public Integer min { get; set; }
        public Integer max { get; set; }

        public IntegerRange(Integer min, Integer max) {
            this.min = min;
            this.max = max;
        }
        
        // Implement the compareTo() method
	    public Integer compareTo(Object compareTo) {
	        IntegerRange compareToEmp = (IntegerRange)compareTo;
	        if (min == compareToEmp.min) return 0;
	        if (min > compareToEmp.min) return 1;
	        return -1;        
	    }
    }
    
    public class Info {
    	public DateTime baselineDate;
    	public Integer cacheTimeout { get; set; }
    	public Integer cvsCovered { get; set; }
    	public Integer farmersReceivingInformation { get; set; }
        public Integer farmersWithPreviousServices { get; set; }
        public Integer farmersGrainChecks { get; set; }
        public Integer inputsPurchased { get; set; }
        public Integer trainingsDoneOnInputAdoption { get; set; }
        public Integer totalInputPrice { get; set; }
        
        public DateTime lastUpdate { get; set; }

        
        public Info(){
        	e_Warehouse_Extra_Info__c ewInfo = null;
            List<e_Warehouse_Extra_Info__c> ewInfoList = [SELECT 
	                                                   Baseline_Date__c, 
	                                                   CVs_Covered__c, 
	                                                   Farmers_receiving_information__c, 
	                                                   Grain_checks_FCI_staff_and_VKWs__c,
	                                                   Volume_of_inputs_fertilizers_purchased__c,
	                                                   Number_of_trainings_on_adoption_of_input__c,
	                                                   Total_price_of_input_purchased__c,
	                                                   Last_update__c 
	                                               FROM e_Warehouse_Extra_Info__c LIMIT 1];
            
            if(ewInfoList.size() == 0){
            	ewInfo = new e_Warehouse_Extra_Info__c();
            	ewInfo.Baseline_Date__c = Date.newInstance(2013, 7, 31);
            	ewInfo.CVs_Covered__c = 0;
            	ewInfo.Farmers_receiving_information__c = 0;
            	ewInfo.Grain_checks_FCI_staff_and_VKWs__c = 0;
            	ewInfo.Number_of_trainings_on_adoption_of_input__c = 0;
            	ewInfo.Volume_of_inputs_fertilizers_purchased__c = 0;
            	ewInfo.Total_price_of_input_purchased__c = 0;
            	ewInfo.Last_update__c = DateTime.now();
            }
            else {
            	ewInfo = ewInfoList[0];
            }
            
            baseLineDate = ewInfo.Baseline_Date__c;
            cvsCovered = Integer.valueOf(ewInfo.CVs_Covered__c);
            farmersReceivingInformation = Integer.valueOf(ewInfo.Farmers_receiving_information__c);
            farmersGrainChecks = Integer.valueOf(ewInfo.Grain_checks_FCI_staff_and_VKWs__c);
            inputsPurchased = Integer.valueOf(ewInfo.Volume_of_inputs_fertilizers_purchased__c);
            trainingsDoneOnInputAdoption = Integer.valueOf(ewInfo.Number_of_trainings_on_adoption_of_input__c);
            totalInputPrice = Integer.valueOf(ewInfo.Total_price_of_input_purchased__c);
            
            lastUpdate = ewInfo.Last_update__c;
            System.debug(LoggingLevel.Debug, 'info: ' + this);
            
        }
        
    }
    
}