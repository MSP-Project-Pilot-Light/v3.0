import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-northeast-1" }));

export const handler = async (event) => {
    console.log("[Pre-Auth - Tokyo]", JSON.stringify(event, null, 2));

    const { userName } = event;
    const email = userName;

    try {
        await docClient.send(new UpdateCommand({
            TableName: process.env.USER_TABLE_NAME,
            Key: { email },
            UpdateExpression: "SET lastLogin = :now, syncStatus = :synced, inactiveDays = :zero",
            ExpressionAttributeValues: {
                ":now": new Date().toISOString(),
                ":synced": "synced",
                ":zero": 0,
            },
        }));

        console.log(`[Tokyo] lastLogin updated: ${email}`);
    } catch (error) {
        console.error("[Tokyo] Failed to update lastLogin:", error);
    }

    return event;
};
