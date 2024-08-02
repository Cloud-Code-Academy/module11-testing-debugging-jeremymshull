/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LeadTriggerHandlerTest {
    @TestSetup
    static void setup(){

        // Create Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Create Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 100; i++) {
            contacts.add(new Contact(
                FirstName = 'ContactFirstName' + i,
                LastName = 'ContactLastName' + i,
                Email = 'email' + i + '@example.com',
                AccountId = accounts[Math.mod(i, accounts.size())].Id
            ));
        }
        insert contacts;

        // Create Leads
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            String title;
            String leadSource;
            String phoneNumber;
            String industry;
            if (Math.mod(i, 12) == 0) {
                title = 'vp of sales';
                leadSource = 'Website';
                phoneNumber = '1234567890';
                industry = 'Technology';
            } else if (Math.mod(i, 12) == 1) {
                title = 'v.p. of marketing';
                leadSource = 'Phone';
                phoneNumber = null;
                industry = 'Finance';
            } else if (Math.mod(i, 12) == 2) {
                title = 'vice president of operations';
                leadSource = 'Website';
                phoneNumber = '0987654321';
                industry = 'Technology';
            } else if (Math.mod(i, 12) == 3) {
                title = 'manager of development';
                leadSource = 'Web';
                phoneNumber = null;
                industry = 'Healthcare';
            } else if (Math.mod(i, 12) == 4) {
                title = 'head of department';
                leadSource = 'Website';
                phoneNumber = '1122334455';
                industry = 'Finance';
            } else if (Math.mod(i, 12) == 5) {
                title = 'chief technology officer';
                leadSource = 'Phone';
                phoneNumber = '2233445566';
                industry = 'Technology';
            } else if (Math.mod(i, 12) == 6) {
                title = 'executive director';
                leadSource = 'Website';
                phoneNumber = null;
                industry = 'Healthcare';
            } else if (Math.mod(i, 12) == 7) {
                title = 'head of sales';
                leadSource = 'Web';
                phoneNumber = '3344556677';
                industry = 'Technology';
            } else if (Math.mod(i, 12) == 8) {
                title = 'assistant manager';
                leadSource = 'Phone';
                phoneNumber = '4455667788';
                industry = 'Finance';
            } else if (Math.mod(i, 12) == 9) {
                title = 'deputy head';
                leadSource = 'Website';
                phoneNumber = null;
                industry = 'Healthcare';
            } else if (Math.mod(i, 12) == 10) {
                title = 'junior developer';
                leadSource = 'Phone';
                phoneNumber = '5566778899';
                industry = 'Technology';
            } else if (Math.mod(i, 12) == 11) {
                title = 'staff assistant';
                leadSource = 'Web';
                phoneNumber = null;
                industry = 'Healthcare';
            }

            if (Math.mod(i, 20) == 0) {
                title = null;
            }

            leads.add(new Lead(
                FirstName = 'FirstName' + i,
                LastName = 'LastName' + i,
                Email = 'email' + i + '@example.com',
                Company = 'Company ' + i,
                Title = title,
                LeadSource = leadSource,
                Phone = phoneNumber,
                Industry = industry
            ));
        }
        insert leads;
    }

    @isTest
    static void handleTitleNormalization_makeConsistentTitles() {
        List<Lead> leads = [SELECT Id, Title FROM Lead];

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();

        for (Lead ld : leads) {
            if (ld.Title != null) {
                if (ld.Title.contains('vp') || ld.Title.contains('v.p.') || ld.Title.contains('vice president')) {
                    Assert.areEqual('Vice President', ld.Title, 'Title was not normalized correctly for: ' + ld.Title);
                } else if (ld.Title.contains('mgr') || ld.Title.contains('manage') || ld.Title.contains('head of department')) {
                    Assert.areEqual('Manager', ld.Title, 'Title was not normalized correctly for: ' + ld.Title);
                } else if (ld.Title.contains('exec') || ld.Title.contains('chief') || ld.Title.contains('head')) {
                    Assert.areEqual('Executive', ld.Title, 'Title was not normalized correctly for: ' + ld.Title);
                } else if (ld.Title.contains('assist') || ld.Title.contains('deputy') || ld.Title.contains('jr')) {
                    Assert.areEqual('Assistant', ld.Title, 'Title was not normalized correctly for: ' + ld.Title);
                } else {
                    // Assert.areEqual(null, ld.Title, 'Unexpected title value: ' + ld.Title);
                }
            } else {
                Assert.areEqual(null, ld.Title, 'Title should be null.');
            }
            
        }
    }
}