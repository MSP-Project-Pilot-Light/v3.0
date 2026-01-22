import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
import bcrypt from "bcryptjs";

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-northeast-1" }));

export const handler = async (event) => {
    console.log("[User Migration - Tokyo]", JSON.stringify(event, null, 2));

    const { triggerSource, userName, request } = event;

    if (triggerSource !== "UserMigration_Authentication") {
        return event;
    }

    const { password } = request;

    try {
        const result = await docClient.send(new GetCommand({
            TableName: process.env.USER_TABLE_NAME,
            Key: { email: userName },
        }));

        if (!result.Item) {
            console.log(`[Tokyo] User not found in DynamoDB: ${userName}`);
            throw new Error("User not found");
        }

        const user = result.Item;
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

        if (!isPasswordValid) {
            console.log(`[Tokyo] Invalid password for user: ${userName}`);
            throw new Error("Invalid password");
        }

        event.response.userAttributes = {
            email: user.email,
            email_verified: "true",
            name: user.userAttributes?.name || "",
            phone_number: user.userAttributes?.phone || "",
        };

        event.response.finalUserStatus = "CONFIRMED";
        event.response.messageAction = "SUPPRESS";

        console.log(`[Tokyo] User migrated successfully: ${userName}`);

        return event;
    } catch (error) {
        console.error("[Tokyo] Migration failed:", error);
        throw error;
    }
};
