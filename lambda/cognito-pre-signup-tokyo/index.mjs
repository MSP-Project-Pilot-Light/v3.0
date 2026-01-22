import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import bcrypt from "bcryptjs";

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-northeast-1" }));

export const handler = async (event) => {
    console.log("[Pre-Signup - Tokyo]", JSON.stringify(event, null, 2));

    const { request, userName } = event;
    const { userAttributes } = request;

    const email = userAttributes.email;
    const userId = userAttributes.sub;
    const rawPassword = request.password || "TEMP_PASSWORD";

    const passwordHash = await bcrypt.hash(rawPassword, 10);

    try {
        await docClient.send(new PutCommand({
            TableName: process.env.USER_TABLE_NAME,
            Item: {
                email,
                userId,
                passwordHash,
                accountStatus: "ACTIVE",
                createdAt: new Date().toISOString(),
                lastLogin: new Date().toISOString(),
                inactiveDays: 0,
                seoulCognitoSub: null,
                tokyoCognitoSub: userId,
                syncStatus: "pending",
                createdInRegion: "tokyo",
                userAttributes: {
                    name: userAttributes.name || "",
                    phone: userAttributes.phone_number || "",
                },
            },
        }));

        console.log(`[Tokyo] User saved with bcrypt hash: ${email}`);
    } catch (error) {
        console.error("[Tokyo] Failed to save user:", error);
        throw error;
    }

    return event;
};
