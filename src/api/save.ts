import { APIGatewayProxyHandlerV2 } from "aws-lambda";
import Joi from "joi";
import { calculateChangeset } from "../domain/session/session";
import { saveSignature, verifyAccount } from "../web3/sign";

const schema = Joi.object({
  sessionId: Joi.string(),
  farmId: Joi.number(),
  sender: Joi.string(),
  signature: Joi.string(),
});

type Body = {
  farmId: number;
  sessionId: string;
  sender: string;
  signature: string;
  hash: string;
};

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  if (!event.body) {
    throw new Error("No body found in event");
  }

  const body: Body = JSON.parse(event.body);
  const valid = schema.validate(body);
  if (valid.error) {
    throw new Error(valid.error.message);
  }

  verifyAccount({
    address: body.sender,
    farmId: body.farmId,
    signature: body.signature,
  });

  const changeset = await calculateChangeset({
    id: Number(body.farmId),
    owner: body.sender,
  });

  const signature = saveSignature({
    sender: body.sender,
    farmId: body.farmId,
    sessionId: body.sessionId,
    ...changeset,
  });

  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      signature,
      farmId: body.farmId,
      sessionId: body.sessionId,
      ...changeset,
    }),
  };
};
