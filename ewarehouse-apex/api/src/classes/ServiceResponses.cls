global abstract with sharing class ServiceResponses {

	public abstract class ServiceResponse {
		String code;
		String description;
	}

	public abstract class ServiceResultResponse {
		String code;
		String description;
		Object result;
		
	}

}