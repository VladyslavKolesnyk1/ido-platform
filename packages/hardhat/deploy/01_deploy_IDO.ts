import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { CONFIG } from "../constants";

const {
  VESTING_PERCENTS,
  PURCHASE_TOKENS,
  IDO_TOKEN_ADDRESS,
  DATA_FEEDS,
  CLIFF_DURATION,
  TOKEN_PRICE,
  SOFT_CAP,
  MAX_CAP,
  MAX_ALLOCATION,
  MIN_ALLOCATION,
  START_TIME,
  END_TIME,
  OWNER,
} = CONFIG;

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, fixture } = hre.deployments;
  let purchaseTokens = PURCHASE_TOKENS;
  let idoToken = IDO_TOKEN_ADDRESS;

  if (hre.network.name === "localhost") {
    await fixture(["mocks"]);

    purchaseTokens = [(await hre.ethers.getContract("PurchaseTokenMock")).address];
    idoToken = (await hre.ethers.getContract("IDOTokenMock")).address;
  }

  await deploy("IDO", {
    from: deployer,
    args: [
      purchaseTokens,
      DATA_FEEDS,
      VESTING_PERCENTS,
      CLIFF_DURATION,
      TOKEN_PRICE,
      SOFT_CAP,
      MAX_CAP,
      MAX_ALLOCATION,
      MIN_ALLOCATION,
      START_TIME,
      END_TIME,
      idoToken,
      OWNER,
    ],
    log: true,
    autoMine: true,
  });
};

export default deploy;

deploy.tags = ["IDO"];
