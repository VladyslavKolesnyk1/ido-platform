import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { CONFIG } from "../constants";

const {
  TICKET_PRICE,
  MIN_TICKETS,
  MAX_TICKETS,
  START_TIME,
  END_TIME,
  SHARE_PER_TICKET,
  PURCHASE_TOKEN_ADDRESS,
  IDO_TOKEN_ADDRESS,
  OWNER,
} = CONFIG;

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, fixture } = hre.deployments;
  let purchaseToken = PURCHASE_TOKEN_ADDRESS;
  let idoToken = IDO_TOKEN_ADDRESS;

  if (hre.network.name === "localhost") {
    await fixture(["mocks"]);

    purchaseToken = (await hre.ethers.getContract("PurchaseTokenMock")).address;
    idoToken = (await hre.ethers.getContract("IDOTokenMock")).address;
  }

  await deploy("RaffleIDO", {
    from: deployer,
    args: [
      TICKET_PRICE,
      MIN_TICKETS,
      MAX_TICKETS,
      START_TIME,
      END_TIME,
      SHARE_PER_TICKET,
      purchaseToken,
      idoToken,
      OWNER,
    ],
    log: true,
    autoMine: true,
  });
};

export default deploy;

deploy.tags = ["RaffleIDO"];
