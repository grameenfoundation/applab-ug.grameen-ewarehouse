package com.himmit.apexapi

import org.scalatest.FunSpec
import org.scalatest.matchers.ShouldMatchers
import org.slf4j.LoggerFactory
import com.himmit.apexapi.authentication.Authenticator
import scala.Predef._
import com.himmit.apexapi.parameter.UpdateClient

/**
 * User: Oskar
 * Date: 21/04/13
 * Time: 13:20
 */
class ClientApiTest  extends FunSpec with ShouldMatchers {
    val logger = LoggerFactory.getLogger(classOf[ClientApiTest])

    val clientId = "3eyUUD" //4euODw (Peter Sellers)
    describe("The SalesForce Client API") {

        info("Authenticate once for all test cases to do with getting objects")

        val apiSession = Authenticator.getSession.getOrElse(
            fail("No valid authentication with SalesForce, cannot continue test")
        )

        val getObject = new ClientService(apiSession)

        it("will return a Client from a Custom APEX API given a existing ID"){

            val resultOption = getObject.getClient(clientId) //

            resultOption should not be(None)
            resultOption.get.client should not be(None)

            val result = resultOption.get
            val resultClient =  resultOption.get.client.get

            logger.info(resultClient.Id + " - " +resultClient.FirstName + " " + resultClient.LastName)

            result.code should be("200")
            result.description should be("OK")

            resultClient.Id should startWith(clientId)
            resultClient.FirstName.get should be("Jane")
            resultClient.LastName.get should be("Fonda")
            resultClient.DateOfBirth.get should startWith("1937-12-21")
            resultClient.PhoneNumber.get should be("+254987654321")
            resultClient.MobileNumber.get should be("+254123456789")
            resultClient.IDNumber.get should be("ID0987654321")
            resultClient.Gender.get should be("Female")
            resultClient.Village.get should be("Kisumu")
            resultClient.District.get should be("Isiolo")
            resultClient.City.get should be("Kisumu city")
            resultClient.Country.get should be("Kenya")

        }
        it("will update a Client from a Custom APEX API given a client object"){

            val resultOption = getObject.updateClient(new UpdateClient(clientId, "Duplicate")) //

            resultOption should not be(None)
            resultOption.get.client should be(None)

            val result = resultOption.get

            result.code should be("200")
            result.description should be("Updated: client id ["+clientId+"], status: [Duplicate]")

        }
        it("will reset (update) a Client from a Custom APEX API given a client object"){

            val resultOption = getObject.updateClient(new UpdateClient(clientId, "Processed")) //

            resultOption should not be(None)
            resultOption.get.client should be(None)

            val result = resultOption.get

            result.code should be("200")
            result.description should be("Updated: client id ["+clientId+"], status: [Processed]")
        }
        it("will return a List of two Clients from a Custom APEX API given a Status Procesed"){

            val result = getObject.getClients("Default")

            result should not be(null)
            result.clients should not be(None)

            val clients =  result.clients.get

            result.code should be("200")
            result.description should be("OK")

            clients.length should be(2)

        }
       /* it("will return a List of one Clients from a Custom APEX API given a Status Duplicate"){

            val result = getObject.getClients("Duplicate")

            result should not be(null)
            result.clients should not be(None)

            val clients =  result.clients.get

            result.code should be("200")
            result.description should be("OK")

            clients.length should be(1)

        }*/
        it("will return a empty List of Clients from a Custom APEX API given a Status Failed"){

            val result = getObject.getClients("Failed")

            result should not be(null)
            result.clients should not be(None)

            val clients =  result.clients.get

            result.code should be("200")
            result.description should be("OK")

            clients.length should be(0)

        }

        it("will update an Array of 2 UpdateClient objects from a Custom APEX API"){

            val updateClients = new Array[UpdateClient](2)
            updateClients(0) = new UpdateClient(Id = "3eyUUD", Status = "Duplicate")
            updateClients(1) = new UpdateClient(Id = "4euODw", Status = "Failed")

            val result = getObject.updateClients(updateClients)

            result should not be(null)
            result.clients should be(None)

            result.code should be("200")
            result.description should be("Update success")


        }

        it("will reset (update) an Array of 2 UpdateClient objects from a Custom APEX API"){

            val updateClients = new Array[UpdateClient](2)
            updateClients(0) = new UpdateClient(Id = "3eyUUD", Status = "Processed")
            updateClients(1) = new UpdateClient(Id = "4euODw", Status = "Processed")

            val result = getObject.updateClients(updateClients)

            result should not be(null)
            result.clients should be(None)

            result.code should be("200")
            result.description should be("Update success")
        }



    }
}