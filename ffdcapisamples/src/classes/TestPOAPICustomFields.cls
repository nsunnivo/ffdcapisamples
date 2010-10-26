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

public with sharing class TestPOAPICustomFields 
{
	public static void createPurchaseInvoiceWithCustomFields()
	{
		// List of Purchase Invoices to create
		List<c2g.CODAAPIPurchaseInvoiceTypes_4_0.PurchaseInvoice> invoices = 
			new List<c2g.CODAAPIPurchaseInvoiceTypes_4_0.PurchaseInvoice>();
		
		{
			// Construct Purchase Invoice (note general use of Reference.Name is not best practice, used here as a convienance)
			c2g.CODAAPIPurchaseInvoiceTypes_4_0.PurchaseInvoice pinv = new c2g.CODAAPIPurchaseInvoiceTypes_4_0.PurchaseInvoice();
			pinv.Account = new c2g.CODAAPICommon.Reference();
			pinv.Account.Name = 'Eversafe Office Supplies';
			pinv.AccountInvoiceNumber = '1';
			pinv.InvoiceTotal = 10.12;		
			c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItem pinvLine = new c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItem();
			pinvLine.Product = new c2g.CODAAPICommon.Reference();
			pinvLine.Product.Name = '2GB RAM';
			pinvLine.Quantity = 1;
			pinvLine.UnitPrice = 10.12;
			pinvLine.EditTaxValue = false;
			c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItems pinvLines = new c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItems();
			pinvLines.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItem>();
			pinvLines.LineItemList.add(pinvLine);
			pinv.LineItems = pinvLines;
			invoices.add(pinv);
		}
		
		{
			// Construct Purchase Invoice (note general use of Reference.Name is not best practice, used here as a convienance)
			c2g.CODAAPIPurchaseInvoiceTypes_4_0.PurchaseInvoice pinv = new c2g.CODAAPIPurchaseInvoiceTypes_4_0.PurchaseInvoice();
			pinv.Account = new c2g.CODAAPICommon.Reference();
			pinv.Account.Name = 'Eversafe Office Supplies';
			pinv.AccountInvoiceNumber = '1';
			pinv.InvoiceTotal = 10.12;		
			c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItem pinvLine = new c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItem();
			pinvLine.Product = new c2g.CODAAPICommon.Reference();
			pinvLine.Product.Name = '2GB RAM';
			pinvLine.Quantity = 1;
			pinvLine.UnitPrice = 10.12;
			pinvLine.EditTaxValue = false;
			c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItems pinvLines = new c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItems();
			pinvLines.LineItemList = new List<c2g.CODAAPIPurchaseInvoiceLineItemTypes_4_0.PurchaseInvoiceLineItem>();
			pinvLines.LineItemList.add(pinvLine);
			pinv.LineItems = pinvLines;
			invoices.add(pinv);
		}
		
		// Call Purchase Invoice Bulk Create API
		List<c2g.CODAAPICommon.Reference> pinvRefs = c2g.CODAAPIPurchaseInvoice_4_0.BulkCreatePurchaseInvoice(null, invoices);
	}
}