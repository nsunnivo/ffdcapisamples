/**
 * Copyright (c) 2009, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

global class SimpleJournalImportBatch
    implements Database.Batchable<SObject>
{
	private final List<ID> m_ids;
	
	public SimpleJournalImportBatch(List<ID> ids)
	{
		m_ids = ids;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext ctx)
	{
		return Database.getQueryLocator([select ID, Name, Value__c, Analysis__c from SimpleJournal__c where Id in :m_ids]);
	}

	global void execute(Database.BatchableContext ctx, List<SObject> records)
	{
		// Names for references to make on the Journals
		final String GLA_NAME_ACCOUNTS_PAYABLE = 'Accounts Payable Control - GBP';
		final String GLA_NAME_BROCHURES = 'Brochures';
		final String GLA_NAME_POSTAGE_AND_STATIONERY = 'Postage and Stationery';
		final String GLA_NAME_TELEPHONES = 'Telephones';
		final String PERIOD_2008_012 = '2008/012';
		final String CURRENCY_GBP = 'GBP';
		
		// Users current company
		List<String> currentCompanies = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null);
		String currentCompany = currentCompanies[0];
		
		// Popupate an ID Name map, FF API works most optimum when given Salesforce record ID's
		Map<String, ID> idNameMap = new Map<String, ID>();
		for(c2g__codaGeneralLedgerAccount__c gla : [select Id, Name from c2g__codaGeneralLedgerAccount__c where Name in :new String[] { GLA_NAME_BROCHURES, GLA_NAME_ACCOUNTS_PAYABLE, GLA_NAME_POSTAGE_AND_STATIONERY, GLA_NAME_TELEPHONES }])
			idNameMap.put(gla.Name, gla.Id);
		for(c2g__codaAccountingCurrency__c curr : [select Id, Name from c2g__codaAccountingCurrency__c where Name in :new String[] { CURRENCY_GBP } and c2g__OwnerCompany__r.Name = :currentCompany ])
			idNameMap.put(curr.Name, curr.Id);
		for(c2g__codaPeriod__c period : [select Id, Name from c2g__codaPeriod__c where Name in :new String[] { PERIOD_2008_012 } and c2g__OwnerCompany__r.Name = :currentCompany ])
			idNameMap.put(period.Name, period.Id);
				
		// Build a list of Journals
		List<c2g.CODAAPIJournalTypes_3_0.Journal> journals = new List<c2g.CODAAPIJournalTypes_3_0.Journal>();
		
		// Process trigger records
		for(SObject record : records)
		{
			SimpleJournal__c simpleJournal = (SimpleJournal__c) record;
			
			// Setup Journal Header
			c2g.CODAAPIJournalTypes_3_0.Journal journal = new c2g.CODAAPIJournalTypes_3_0.Journal();
			journal.JournalCurrency = new c2g.CODAAPICommon.Reference();
			journal.JournalCurrency.Id = idNameMap.get(CURRENCY_GBP);
			journal.Period = new c2g.CODAAPICommon.Reference();
			journal.Period.Id = idNameMap.get(PERIOD_2008_012);
			journal.Reference = simpleJournal.Name;
			journal.JournalDate = Date.today();
			journal.JournalDescription = 'Example Journal from API';
			journal.JournalStatus = c2g.CODAAPIJournalTypes_3_0.enumJournalStatus.InProgress;
			journal.TypeRef = c2g.CODAAPIJournalTypes_3_0.enumType.ManualJournal;
			
			// Setup Journal Line Items 
			c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItems lineItems = new c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItems();
			lineItems.LineItemList = new List<c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItem>();
			journal.LineItems = lineItems;
			
			// Create Line 1
			c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItem lineItem1 = new c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItem();
			lineItem1.LineTypeRef = c2g.CODAAPIJournalLineItemTypes_3_0.enumLineType.GeneralLedgerAccount;
			lineItem1.GeneralLedgerAccount = new c2g.CODAAPICommon.Reference();
			lineItem1.GeneralLedgerAccount.Id = idNameMap.get(GLA_NAME_ACCOUNTS_PAYABLE); 
			lineItem1.Value = simpleJournal.Value__c * -1;
			lineItems.LineItemList.add(lineItem1);
		
			// Create Line 2
			c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItem lineItem2 = new c2g.CODAAPIJournalLineItemTypes_3_0.JournalLineItem();
			lineItem2.LineTypeRef = c2g.CODAAPIJournalLineItemTypes_3_0.enumLineType.GeneralLedgerAccount;
			lineItem2.GeneralLedgerAccount = new c2g.CODAAPICommon.Reference();
			lineItem2.GeneralLedgerAccount.Id = idNameMap.get(simpleJournal.Analysis__c); 
			lineItem2.Value = simpleJournal.Value__c;
			lineItems.LineItemList.add(lineItem2);
		
			// Add Journal to bulk list		
			journals.add(journal);
		}
		
		// Bulk Create and Post Journals
		c2g.CODAAPICommon_3_0.Context context = new c2g.CODAAPICommon_3_0.Context(); // No need to override users default company
		List<c2g.CODAAPICommon.Reference> refs = c2g.CODAAPIJournal_3_0.BulkCreateJournal(context, journals);
		c2g.CODAAPIJournal_3_0.BulkPostJournal(context, refs);
		
		// Update Simple Journals with references
		Integer idx = 0;
		for(SObject record : records)
		{
			SimpleJournal__c simpleJournal = (SimpleJournal__c) record;
			simpleJournal.Journal__c = refs[idx].Id;			
			idx++;
		}				
		update records;		
	}
	
   	global void finish(Database.BatchableContext ctx)
   	{
   	}
}