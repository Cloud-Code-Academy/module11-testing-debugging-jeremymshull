/**
 * This class contains unit tests for validating the behavior of LeadTrigger and LeadTriggerHandler
 */
@isTest
private class LeadTriggerHandlerTest {
    
    // Method creating test data for tests. Creates Accounts, Contacts, and leads with varied attributes
    @TestSetup
    static void setup(){

        // Create Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Create Contacts with varied emails and associate with an Account
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

        // Create Leads with varied attributes
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

            // Set title to null for some leads to test null cases
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
    static void handleTitleNormalization_normalizeTitles() {
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
                }
            } else {
                Assert.areEqual(null, ld.Title, 'Title should be null.');
            }
            
        }
    }

    @isTest
    static void handleTitleNormalization_updateTitles() {
        List<Lead> leads = [SELECT Id, Title FROM Lead];

        // Update titles to test Before_Update context
        for (Lead ld : leads) {
            ld.Title = 'updated ' + (ld.Title == null ? 'title' : ld.Title);
        }

        Test.startTest();
        update leads;
        Test.stopTest();

        // Query for leads to verify updates
        leads = [SELECT Id, Title FROM Lead WHERE Id IN :leads];

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
                }
            } else {
                Assert.areEqual(null, ld.Title, 'Title should be null.');
            }
        }
    }

    @IsTest 
    static void handleAutoLeadScoring_addLeadScore() {
        List<Lead> leads = [SELECT Id, LeadSource, Phone, Email, Industry, Lead_Score__c FROM Lead];


        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        for (Lead ld : leads) {
            Integer expectedScore = 0;
            if (ld.LeadSource == 'Website' && lead.Email != null) {
				expectedScore += 3;
			}

			if (ld.Phone != null) {
				expectedScore += 5;
			}

			if (ld.Industry == 'Technology') {
				expectedScore += 10;
			}
            expectedScore = Math.min(expectedScore, 18);

            Assert.areEqual(expectedScore, ld.Lead_Score__c, 'Score was not calculated correctly for: ' + ld);
        }
    }

    @IsTest 
    static void handleAutoLeadScoring_updateLeadScore() {
        List<Lead> leads = [SELECT Id, LeadSource, Phone, Email, Industry, Lead_Score__c FROM Lead];

        // Update lead records to test Before_Update
        for (Lead ld : leads) {
            ld.LeadSource = 'Phone';
            ld.Phone = '9998887777';
            ld.Industry = 'Finance';
        }

        Test.startTest();
        update leads;
        Test.stopTest();

        leads = [SELECT Id, LeadSource, Phone, Email, Industry, Lead_Score__c FROM Lead WHERE Id IN :leads];

        for (Lead ld : leads) {
            Integer expectedScore = 0;
            if (ld.LeadSource == 'Website' && ld.Email != null) {
				expectedScore += 3;
			}

			if (ld.Phone != null) {
				expectedScore += 5;
			}

			if (ld.Industry == 'Technology') {
				expectedScore += 10;
			}
            expectedScore = Math.min(expectedScore, 18);

            Assert.areEqual(expectedScore, ld.Lead_Score__c, 'Score was not updated correctly for: ' + ld);
        }
    }

    @IsTest
    static void handleLeadAutoConvert_convertLeads() {
        List<Contact> contacts = [SELECT Id, Email, AccountId FROM Contact];
        Set<String> contactEmails = new Set<String>();
        Map<String, Id> emailToContactIdMap = new Map<String, Id>();
        
        for (Contact c : contacts) {
            if (c.Email != null) {
                contactEmails.add(c.Email);
                emailToContactIdMap.put(c.Email, c.Id);
            }    
        }

        List<Lead> leads = [SELECT Id, Email FROM Lead WHERE Email IN :contactEmails];

        Test.startTest();
        LeadTriggerHandler.handleLeadAutoConvert(leads);
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, Email, IsConverted, ConvertedContactId FROM Lead WHERE Id IN :leads];

        for (Lead updatedLead : updatedLeads) {
            Id contactId = emailToContactIdMap.get(updatedLead.Email);
            
            if (contactId != null) {
                Assert.isTrue(updatedLead.IsConverted, 'Lead should have been converted for: ' + updatedLead.Email);
                Assert.areEqual(contactId, updatedLead.ConvertedContactId, 'Lead was not converted to the correct Contact for: ' + updatedLead.Email);
            } else {
                Assert.isTrue(!updatedLead.IsConverted, 'Lead should not have been converted for: ' + updatedLead.Email);
            }
        }
    }
    
    @isTest
    static void HandleLeadAutoConvert_nullEmails() {
        // Create Accounts
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Create Contacts with unique emails
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                FirstName = 'ContactFirstName' + i,
                LastName = 'ContactLastName' + i,
                Email = 'email' + i + '@example.com',
                AccountId = account.Id
            ));
        }
        insert contacts;

        // Create Leads, with some having null email addresses
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            leads.add(new Lead(
                FirstName = 'LeadFirstName' + i,
                LastName = 'LeadLastName' + i,
                Company = 'Company' + i,
                Email = Math.mod(i, 2) == 0 ? null : 'email' + i + '@example.com' // alternate between null and valid email
            ));
        }
        insert leads;

        // Run the trigger handler method
        Test.startTest();
        LeadTriggerHandler.handleLeadAutoConvert(leads);
        Test.stopTest();

        // Query the leads again to check conversion status
        List<Lead> updatedLeads = [SELECT Id, IsConverted, Email FROM Lead WHERE Id IN :leads];
        
        // Verify that leads with null emails have not been converted
        for (Lead ld : updatedLeads) {
            if (ld.Email == null) {
                Assert.areEqual(false, ld.IsConverted, 'Lead with null email should not be converted: ' + ld.Id);
            } 
        }
    }
}