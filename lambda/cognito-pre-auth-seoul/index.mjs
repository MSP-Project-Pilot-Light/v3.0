import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-northeast-2" }));

export const handler = async (event) => {
    console.log("[Pre-Auth - Seoul]", JSON.stringify(event, null, 2));

    const { userName } = event;
    const email = userName;

    try {
        // DynamoDB lastLogin 업데이트
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

        console.log(`[Seoul] lastLogin updated: ${email}`);
    } catch (error) {
        console.error("[Seoul] Failed to update lastLogin:", error);
        // Pre-Auth는 실패해도 로그인 계속 진행
    }

    return event;
};
