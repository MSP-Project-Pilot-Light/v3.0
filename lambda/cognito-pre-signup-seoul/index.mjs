import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import bcrypt from "bcryptjs";

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-northeast-2" }));

export const handler = async (event) => {
    console.log("[Pre-Signup - Seoul]", JSON.stringify(event, null, 2));

    const { request, userName } = event;
    const { userAttributes } = request;

    const email = userAttributes.email;
    const userId = userAttributes.sub;

    // Cognito에서 안전하게 비밀번호 전달받음
    const rawPassword = request.password || "TEMP_PASSWORD";

    // bcrypt 암호화 (Cost Factor 10)
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
                seoulCognitoSub: userId,
                tokyoCognitoSub: null,
                syncStatus: "pending",
                createdInRegion: "seoul",
                userAttributes: {
                    name: userAttributes.name || "",
                    phone: userAttributes.phone_number || "",
                },
            },
        }));

        console.log(`[Seoul] User saved with bcrypt hash: ${email}`);
    } catch (error) {
        console.error("[Seoul] Failed to save user:", error);
        throw error;
    }

    return event;
};
