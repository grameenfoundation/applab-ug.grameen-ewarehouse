global with sharing class Client {
	
	public String id { get; set; }
	public String FirstName { get; set; }
    public String LastName { get; set; }
    public DateTime DateOfBirth { get; set; }
    public String PhoneNumber { get; set; }
    public String MobileNumber { get; set; }
    public String IDNumber { get; set; }
    public String Gender { get; set; }
    public String Address1 { get; set; }
    public String Address2 { get; set; }
    public String City { get; set; }
    public String Country { get; set; }
    
    public static fromFarmer(Farmer__c farmer){
    	
        Client client = new Client();
    			
    	client.id = farmer.ID;
		client.FirstName = farmer.ID;
	    client.LastName = farmer.ID;
	    client.DateOfBirth = farmer.ID;
	    client.PhoneNumber = farmer.ID;
	    client.MobileNumber = farmer.ID;
	    client.IDNumber = farmer.ID;
	    client.Gender = farmer.ID;
	    client.Address1 = farmer.ID;
	    client.Address2 = farmer.ID;
	    client.City = farmer.ID;
	    client.Country = farmer.ID;
		
		return client;
    }
    
    /*
    {“id”: “arX093883ug”, 
     “FirstName” : “Test Name”, 
     “LastName” : “Test Name”, 
     “DateOfBirth” : “01-01-1960”, 
     “PhoneNumber” : “+254712123456”, 
     “MobileNumber”: “+254712123456”, 
     “IDNumber” : “12345678”, 
     “Gender” : “Male”, 
     “Address1” : “Village”, 
     “Address2”: “District”, 
     “City”: “Meru”, 
     “Country”: “Kenya”}
*/

}