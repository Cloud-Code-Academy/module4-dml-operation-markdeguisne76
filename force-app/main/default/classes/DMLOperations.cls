/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Your Name
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        Account firstAcc = new Account();// Create a new Account instance

        // Set some fields on the Account
        firstAcc.BillingCity = 'Tulsa';
        firstAcc.Name = 'Emu Factory';
        firstAcc.NumberOfEmployees = 1000;
        // Insert the Account into the database
        insert firstAcc;
        System.debug('New Account inserted with Id: ' + firstAcc.Id);
        // Return the Id of the newly created Account
        return firstAcc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account secondAcc = new Account();
        secondAcc.Name = name;
        secondAcc.Industry = industry;
        // Insert the Account
        insert secondAcc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact firstCon = new Contact();
        // Set some fields on the Contact
        firstCon.LastName = 'Doe';
        // Set the AccountId field to the given accountId
        firstCon.AccountId = accountId;
        // Insert the Contact into the database
        insert firstCon;
        // Return the Id of the newly created Contact
        return firstCon.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact conToUpdate = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        conToUpdate.LastName = newLastName;
        // Update the Contact in the database
        update conToUpdate;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity oppToUpdate = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        oppToUpdate.StageName = newStage;
        // Update the Opportunity in the database
        update oppToUpdate;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account accToUpdate = [SELECT Id FROM Account WHERE Id = :accountId];
        accToUpdate.Name = newName;
        accToUpdate.Industry = newIndustry;
        // Update the Account with the given Id with the new name and industry
        update accToUpdate;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for (Opportunity oppsToUpdateinList : opportunities) {
            oppsToUpdateinList.StageName = 'Qualification';
            oppsToUpdateinList.CloseDate = Date.today().addMonths(3);
            oppsToUpdateinList.Amount = 50000;
        }
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Loop through each Opportunity name
        if (String.isBlank(accountName) || oppNames.isEmpty()) {
            return;
        }
        List<Account> accList = [SELECT Id FROM Account WHERE Name = :accountName];
        Account findAccts;
        if (accList.isEmpty()) {
            findAccts = new Account(Name = accountName);
            upsert findAccts;
        } else {
            findAccts = accList[0];
        }
        Map<String, Opportunity> existingOpps = new Map<String, Opportunity>();
        for (Opportunity oppsToLoopThru : [SELECT Id, Name FROM Opportunity WHERE AccountId = :findAccts.Id AND Name IN :oppNames]) {
            existingOpps.put(oppsToLoopThru.Name, oppsToLoopThru);
        }
            // Create an Opportunity with the given name
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
        for (String oppName : oppNames) {
            if (!existingOpps.containsKey(oppName)) {
                oppsToUpsert.add(new Opportunity(Name = oppName, AccountId = findAccts.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30)));
            }
        }
            // Add the Opportunity to the list
        if (!oppsToUpsert.isEmpty()) {
            upsert oppsToUpsert;
        }
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

		// if the Account exists, update the description
        if (String.isBlank(accountName)) {
            return null;
        }
        List<Account> getAccts = [SELECT Id, Description FROM Account WHERE Name = :accountName LIMIT 1];
        Account newAcct;
		// otherwise, create a new Account and set the description
        if (!getAccts.isEmpty()) {
            newAcct = getAccts[0];
            newAcct.Description = 'Updated Account';
        } else {
            newAcct = new Account(Name = accountName, Description = 'New Account');
        }
		// Upsert the Account
        upsert newAcct;
		return newAcct;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        if (contactsToUpsert.isEmpty()) {
            return;
        }
		// Extract the Account Name from Contact's LastName
        Set<String> acctNames = new Set<String>();
        for (Contact contactCheck : contactsToUpsert) {
            if (!String.isBlank(contactCheck.LastName)) {
                acctNames.add(contactCheck.LastName);
            }
        }
		// Get the account based on the name or create one if it doesn't exist
        Map<String, Account> existingAccounts = new Map<String, Account>();
        for (Account accCheck : [SELECT Id, Name FROM Account WHERE Name IN :acctNames]) {
            existingAccounts.put(accCheck.Name, accCheck);
        }
        List<Account> newAccounts = new List<Account>();
        for (String acctName : acctNames) {
            if (!existingAccounts.containsKey(acctName)) {
                Account createNewAccount = upsertAccount(acctName);
                existingAccounts.put(acctName, createNewAccount);
            }
        }
		// Link the Contact to its Account using the Account Id
        for (Contact contactCheck : contactsToUpsert) {
            if (!String.isBlank(contactCheck.LastName) && existingAccounts.containsKey(contactCheck.LastName)) {
                contactCheck.AccountId = existingAccounts.get(contactCheck.LastName).Id;
            }
        }
		// Upsert the Contacts
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        if (leadNames.isEmpty()) {
            return;
        }
        // Create a list to store the Leads
        List<Lead> leadsToCreate = new List<Lead>();

        for (String leadName : leadNames) {
            if (!String.isBlank(leadName)) {
                Lead newLead = new Lead(LastName = leadName, Company = 'Test Company');
                leadsToCreate.add(newLead);
                System.debug('Created Lead: ' + newLead);
            }
        }
        // check if the new list is empty
        if (leadsToCreate.isEmpty()) {
            return;
        }
        // Insert the Leads 
        insert leadsToCreate;
        // Delete the Leads
        delete leadsToCreate;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        List<Case> caseList = new List<Case>();
        for (Integer i = 0; i < numOfCases; i++) {
            Case casesForAcct = new Case();
            casesForAcct.AccountId = accountId;
            caseList.add(casesForAcct);
        }
        insert caseList;
        // Delete the cases
        delete caseList;
    }
}