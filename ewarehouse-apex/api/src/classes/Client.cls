global with sharing class Client {
	
	public String Id { get; set; }
	public String FirstName { get; set; }
    public String LastName;
    public Date DateOfBirth { get; set; }
    public String PhoneNumber { get; set; }
    public String MobileNumber { get; set; }
    public String IDNumber { get; set; }
    public String Gender { get; set; }
    public String Village { get; set; }
    public String District { get; set; }
    public String City { get; set; }
    public String Country { get; set; }
    public String PictureURL { get;set; }
    
    public static Client fromFarmer(Farmer__c farmer){
    	
    	// get a reference of the farmer's person object
    	Person__c personRef = farmer.Person__r;
    	District__c districtRef = personRef.District__r;
    	Country__c countryRef = personRef.Country__r;
    	
    	// create new client
        Client client = new Client();
    	
    	client.Id = farmer.Name;
    	
    	// take the information from the referenced objects when they are available
    	if(personRef != null){
    		client.FirstName = personRef.First_Name__c;
		    client.LastName = personRef.Last_Name__c;
		    client.DateOfBirth = personRef.Date_of_Birth__c;
		    client.PhoneNumber = personRef.Phone_Number__c;
		    client.MobileNumber = personRef.Mobile_Number__c;
		    client.IDNumber = personRef.ID_Number__c;
		    client.Gender = personRef.Gender__c;
		    client.Village = personRef.Village__c;
		    client.City = personRef.City__c;
		    client.PictureURL = personRef.Picture_URL__c;
    	}
    	
    	if(districtRef != null)
			client.District = districtRef.Name;
			
		if(countryRef != null)
	    	client.Country = countryRef.Name;
	    
		System.debug(client);
		
		return client;
    }
}