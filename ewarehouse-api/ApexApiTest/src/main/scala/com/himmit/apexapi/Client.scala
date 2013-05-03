package com.himmit.apexapi

import java.util.Date

/**
 * User: Oskar
 * Date: 27/04/13
 * Time: 16:48
 */
case class Client(Id: String,
                  FirstName: Option[String],
                  LastName: Option[String],
                  DateOfBirth: Option[String],
                  PhoneNumber: Option[String],
                  MobileNumber: Option[String],
                  IDNumber: Option[String],
                  Gender: Option[String],
                  Village: Option[String],
                  District: Option[String],
                  City: Option[String],
                  Country: Option[String]) {

}
