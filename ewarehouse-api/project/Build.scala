import sbt._
import Keys._

object ApplicationBuild extends Build {

    val appName = "ApexApiTest"
    val appLocation = "ApexApiTest"
    val appVersion = "1.0"
	
    val appDependencies = Seq(
        "org.scalatest" %% "scalatest" % "1.9.1" % "test",
        "net.databinder.dispatch" %% "dispatch-core" % "0.10.0",
		"joda-time" % "joda-time" % "2.2",
		"org.joda" % "joda-convert" % "1.2",
		"org.slf4j" % "slf4j-api" % "1.7.5",
		"ch.qos.logback" % "logback-classic" % "1.0.11",
		"io.spray" %  "spray-json_2.10" % "1.2.3")

    val appResolvers = Seq(
		"spray repo" at "http://repo.spray.io")

    val aApexApiTest = Project(appName, file(appLocation),
        settings = Defaults.defaultSettings)
        .settings(
            version := appVersion,
            scalaVersion := "2.10.1",
            libraryDependencies := appDependencies,
            resolvers := appResolvers)

}
//"spray repo" at "http://repo.spray.io".
		