import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
import bcrypt from "bcryptjs";

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-northeast-2" }));

export const handler = async (event) => {
    console.log("[User Migration - Seoul]", JSON.stringify(event, null, 2));

    const { triggerSource, userName, request } = event;

    // User Migration Trigger만 처리
    if (triggerSource !== "UserMigration_Authentication") {
        return event;
    }

    const { password } = request;

    try {
        // DynamoDB에서 사용자 조회
        const result = await docClient.send(new GetCommand({
            TableName: process.env.USER_TABLE_NAME,
            Key: { email: userName },
        }));

        if (!result.Item) {
            console.log(`[Seoul] User not found in DynamoDB: ${userName}`);
            throw new Error("User not found");
        }

        const user = result.Item;

        // bcrypt 비밀번호 검증
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

        if (!isPasswordValid) {
            console.log(`[Seoul] Invalid password for user: ${userName}`);
            throw new Error("Invalid password");
        }

        // Cognito User Pool에 사용자 자동 생성
        event.response.userAttributes = {
            email: user.email,
            email_verified: "true",
            name: user.userAttributes?.name || "",
            phone_number: user.userAttributes?.phone || "",
        };

        event.response.finalUserStatus = "CONFIRMED";
        event.response.messageAction = "SUPPRESS";

        console.log(`[Seoul] User migrated successfully: ${userName}`);

        return event;
    } catch (error) {
        console.error("[Seoul] Migration failed:", error);
        throw error;
    }
};
