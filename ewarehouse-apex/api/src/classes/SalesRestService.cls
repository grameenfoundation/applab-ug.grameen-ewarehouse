@RestResource(urlMapping='/ewarehouse/sales/*')
global class SalesRestService extends EwarehouseServiceBase  {
	
	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getSales() {
    	return new SaleResponse(new Sale[]{});
    }
    
    global class SaleResponse extends ServiceResultResponse {
		public SaleResponse(Sale[] sales){
			this.code = '200';
			this.description = 'Not yet implemented';//'OK';
			this.sales = sales;
		}
		
		public Sale[] sales;
	}
	
	public class Sale {
		public String Id { get; set; }
		public Decimal Amount { get; set; }
		public SaleFarmer[] SaleFarmers { get; set; }
	}
	
	public class SaleFarmer {
		public String FarmerId { get; set; }
		public Decimal AmountApplied { get; set; }
	}
	
}