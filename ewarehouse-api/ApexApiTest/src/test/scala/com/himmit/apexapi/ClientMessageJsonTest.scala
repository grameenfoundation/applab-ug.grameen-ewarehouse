package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import com.himmit.apexapi.response.{ClientsResponse, ClientResponse}
import spray.json.JsonParser
import com.himmit.apexapi.base.JsonConfigurator
import JsonConfigurator._
import scala.util.parsing.json.JSONObject
import com.himmit.apexapi.parameter.UpdateClient

/**
 * User: Oskar
 * Date: 29/04/13
 * Time: 13:38
 */
class ClientMessageJsonTest extends FunSpec with ShouldMatchers {
    val jsonString = """{"code": "200", "description": "OK", "client": {"id": "arX093883ug", "FirstName" : "Test Name", "LastName" : "Test Name", "DateOfBirth" : "01-01-1960", "PhoneNumber" : "+254712123456", "MobileNumber": "+254712123456", "IDNumber" : "12345678", "Gender" : "Male", "Address1" : "Village", "Address2": "District", "City": "Meru", "Country": "Kenya"}}"""
    val jsonClientsString =
        """{"code": "200", "description": "OK", "clients":
          [{"id": "arX093883ug", "FirstName" : "Test Name1", "LastName" : "Test Name", "DateOfBirth" : "01-01-1960", "PhoneNumber" : "+254712123456", "MobileNumber": "+254712123456", "IDNumber" : "12345678", "Gender" : "Male", "Address1" : "Village", "Address2": "District", "City": "Meru", "Country": "Kenya"},
          {"id": "arX093883ug", "FirstName" : "Test Name2", "LastName" : "Test Name", "DateOfBirth" : "01-01-1960", "PhoneNumber" : "+254712123456", "MobileNumber": "+254712123456", "IDNumber" : "12345678", "Gender" : "Male", "Address1" : "Village", "Address2": "District", "City": "Meru", "Country": "Kenya"}]}"""
    val jsonNoClientString = """{"code": "200", "description": "OK"}"""

    describe("spray-json can deserialize json nested objects") {

        it("will return a ClientResponse from a JSON string"){
            val jsonResult = JsonParser(jsonString)
            val myObject = jsonResult.convertTo[ClientResponse]

            myObject.code should be("200")
            myObject.description should be("OK")
            myObject.client.get.FirstName should be("Test Name")
        }
        it("will return a ClientsResponse from a JSON string with 2 clients"){
            val jsonClients = JsonParser(jsonClientsString)
            val myObject = jsonClients.convertTo[ClientsResponse]

            myObject.code should be("200")
            myObject.description should be("OK")
            myObject.clients.get(0).FirstName should be("Test Name1")
            myObject.clients.get(1).FirstName should be("Test Name2")
        }
        it("will return a ClientResponse without objects from a JSON string without clients"){
            val jsonResult = JsonParser(jsonNoClientString)
            val myObject = jsonResult.convertTo[ClientResponse]

            myObject.code should be("200")
            myObject.description should be("OK")
            myObject.client should be(None)
        }
        it("will return a ClientsResponse without objects from a JSON string without clients"){
            val jsonClients = JsonParser(jsonNoClientString)
            val myObject = jsonClients.convertTo[ClientsResponse]

            myObject.code should be("200")
            myObject.description should be("OK")
            myObject.clients should be(None)
        }
        it("will convert a Map[String, String] into a nice parameter json"){
            val updateClient = new UpdateClient("id-string", "Duplicate")
            val parameters = Map[String, String](
                "id" -> updateClient.id,
                "status" -> updateClient.status
            )
            val jsonBody = JSONObject(parameters).toString()
            jsonBody should be("""{"id" : "id-string", "status" : "Duplicate"}""")

        }
    }
}
