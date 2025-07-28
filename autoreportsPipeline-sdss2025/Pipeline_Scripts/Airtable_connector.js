// AWS API Gateway endpoint URL
let inputConfig = input.config();
const apiGatewayUrl = inputConfig.apiGatewayUrl;

// Define headers for the POST request (including API key)
const headers = {
    'Content-Type': 'application/json',
    'x-api-key': inputConfig.aws_api_key,
};

// Airtable setup
const generateReportsTable = base.getTable("tblUSflBxiARJMnXP"); // Generate Reports table ID
const statusFieldId = 'fldwLs4vXz8tFc8Fk'; // Status field ID

const yr2Table = base.getTable("tblMjkfDgd9o3ORp8"); // YR 2_IL NA School Information table ID
const v2FieldId = 'fld5adHRedAPiZOpc'; // V2 field ID

// Function to update the "Status" field in Airtable
async function updateAirtableStatus(recordId, newStatus) {
    try {
        await generateReportsTable.updateRecordsAsync([
            {
                id: recordId,
                fields: { [statusFieldId]: { name: newStatus } }, // Single-select format
            },
        ]);
        console.log(`Status updated to: ${newStatus}`);
    } catch (error) {
        console.error(`Error updating status for record ${recordId}:`, error);
    }
}

// Function to check V2 status in YR 2 table
async function checkV2Statuses() {
    try {
        // Fetch all V2 records from the YR 2_IL NA School Information table
        let yr2Query = await yr2Table.selectRecordsAsync({ fields: [v2FieldId] });

        // Check for "GENERATING REPORT" or "ERROR" statuses
        let conflictingRecord = yr2Query.records.find(record => {
            let status = record.getCellValue(v2FieldId)?.name;
            return status === 'GENERATING REPORT' || status === 'ERROR';
        });

        return conflictingRecord !== undefined;
    } catch (error) {
        console.error('Error checking V2 statuses:', error);
        return true; // Assume a conflict if check fails
    }
}

// Function to check if there are any records with status "READY"
async function hasReadyRecords() {
    try {
        let records = await generateReportsTable.selectRecordsAsync({ fields: [statusFieldId] });
        return records.records.filter(record => {
            let status = record.getCellValue(statusFieldId)?.name;
            return status === 'READY';
        });
    } catch (error) {
        console.error('Error checking READY records:', error);
        return []; // Return empty array if there's an error
    }
}

async function triggerLambda() {
    console.log('Checking V2 statuses before triggering Lambda...');
    let hasConflict = await checkV2Statuses();

    if (hasConflict) {
        console.log('Lambda trigger blocked: V2 status is "GENERATING REPORT" or "ERROR".');
        return; // Exit if any conflicting status is found
    }

    // Check for records with status "READY" before proceeding
    let readyRecords = await hasReadyRecords();
    if (readyRecords.length === 0) {
        console.log('No records with status "READY" found. Exiting process.');
        return;
    }

    try {
        let response = await fetch(apiGatewayUrl, {
            method: 'POST',
            headers: headers,
        });

        if (response.ok) {
            console.log('Lambda triggered successfully.');
            let responseBody = await response.json();
            console.log('Response:', responseBody);

            // Update each record to "GENERATING REPORTS"
            for (let record of readyRecords) {
                await updateAirtableStatus(record.id, 'GENERATING REPORTS');
            }
            console.log(`Updated ${readyRecords.length} records to "GENERATING REPORTS".`);
        } else {
            console.error(
                `Lambda trigger failed. HTTP Status: ${response.status} - ${response.statusText}`
            );

            // Update all READY records to "ERROR"
            for (let record of readyRecords) {
                await updateAirtableStatus(record.id, 'ERROR');
            }
            console.log(`Updated ${readyRecords.length} records to "ERROR" due to trigger failure.`);
        }
    } catch (error) {
        console.error('Error triggering Lambda:', error);

        // Update all READY records to "ERROR" on exception
        for (let record of readyRecords) {
            await updateAirtableStatus(record.id, 'ERROR');
        }
        console.log(`Updated ${readyRecords.length} records to "ERROR" due to an unexpected error.`);
    }
}


// Run the function to trigger Lambda and update status
await triggerLambda();

