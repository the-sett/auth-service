Auth Server
===========

Auth server is a simple authentication and user permissions management system.
Its feature set is as follows:

* REST API.
* Supports direct authentication of users by username/password.
* Uses JWT tokens.
* Supports Users, Roles and Permissions.
* Can be clustered.
* Provides an API for dependant services to obtain JWT verification keys.

Future directions are likely to cover:

* Creation of User accounts through federated authentication services such as Facebook Connect.
* Management and configuration of multiple authentication end points for applications.

Build Instructions
------------------

Once you have cloned the source code:

    mvn clean install
    ./refresh_db
    ./run

The 'refresh_db' script requires the invoking user to have super user rights on a Postgres database called 'authdb'.    

Point your browser to:

    http://localhost:9073/auth-service/

And log in as admin/admin.


Database Migration
------------------

Note: For release versions only, not SNAPSHOTs.

When the database is to be migrated to a new release version, the DropWizard migration can be invoked like this:

    java -jar auth_top-1.0.jar db migrate config.yml

Obviously, the database should be backed up prior to doing this. Note that there are commands to perform dry runs, and also to tag the schema, so that changes can be rolled back if required. See here for some more information:

http://dropwizard.readthedocs.org/en/latest/manual/migrations.html


Note: For development versions only, that is those ending with SNAPSHOT in the version name.

The migration scripts may be altered during development in order to prepare them for release. Only the migration scripts relating to the current version should ever be touched, previous version must be preserved. Due to the most recent version changing, it is better to completely wipe out and re-create the development database each time. This can be accomplished with these commands:

    java -jar auth_top-1.0-SNAPSHOT.jar db drop-all --confirm-delete-everything config.yml
    java -jar auth_top-1.0-SNAPSHOT.jar db migrate config.yml

Hibernate can generate the database schema automatically, and a build profile has been set up to do this. Run:

        mvn clean install -Pschemagen

The output schema will be in "top/target/schema-create.ddl".


Integration Testing
-------------------

Integration tests require a database to be set up in order to run, so they have been placed under separate source roots named 'src/integrationtests'. These can be run by making use of the 'it' build profile. For example:

    mvn clean install -Pit

The integration tests will perform a drop-create on the database, leaving the database with an up to date schema loaded.


Code Coverage and Sonar
-----------------------

Sonar can apply quality metrics to the code. Some additional configuration around sonar has been included in the Maven build, so that test coverage reports work correctly when a test in one module exercises code in another, and also for integration tests. The test coverage reports are aggregated accross the whole project. To run the full quality metrics through sonar use:

    mvn clean verify sonar:sonar -Pit,sonar


It can be useful to generate the coverage without running the full Sonar QA procedure.

To generate unit test coverage only:

    mvn clean install -Psonar

To generate unit and integration test coverage:

    mvn clean verify -Psonar,it

Once coverage is generated, it will be stored under 'code-coverage/jacoco.exec'. To create the report run:

    ./jacoco_report

This will invoke an Ant script to produce the report. Load the file at 'code-coverage/index.html' to view the report.
